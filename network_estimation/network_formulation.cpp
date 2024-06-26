#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <vector>
#include <cmath>

namespace py = pybind11;

// this is the code to calculate the geospatial distance
double calculate_distance(const std::vector<double> &point1, const std::vector<double> &point2) {
    const double earth_radius_km = 6371.0;
    const double deg_to_rad = M_PI / 180.0;

    double lat1_rad = point1[1] * deg_to_rad;
    double lon1_rad = point1[0] * deg_to_rad;
    double lat2_rad = point2[1] * deg_to_rad;
    double lon2_rad = point2[0] * deg_to_rad;

    double dlon = lon2_rad - lon1_rad;
    double dlat = lat2_rad - lat1_rad;
    double a = std::sin(dlat / 2) * std::sin(dlat / 2) + std::cos(lat1_rad) * std::cos(lat2_rad) * std::sin(dlon / 2) * std::sin(dlon / 2);
    double c = 2 * std::atan2(std::sqrt(a), std::sqrt(1 - a));
    double distance_km = earth_radius_km * c;

    return distance_km * 1000; // Convert to meters
}


std::pair<std::vector<std::vector<int>>, std::vector<std::tuple<int, int, double>>> network_formation(
    // 匹配门店和社区：将每个门店与给定半径内的社区匹配。
    // 计算边的效应值：构建门店和社区的配对，并将效应值分配给边。
    // 连接共享社区的门店：将具有共同社区的门店连接起来，并将边的权重设为共享社区效应值的和。
    // 折扣因子：对于共享邻居的情况，应用折扣因子，以反映共享效应的折减。
    // 对于具有共同邻居的情况，应用折扣因子。折扣因子可以定义为共享社区效应值之和除以两个门店效应值之和的比值。

    // 所以我们的store与store之间的关联会是0 < x < 1/2，所以我们可以保证A*B*C的时候这个效应会逐步降低
    const std::vector<std::vector<double>> &stores, 
    const std::vector<std::vector<double>> &communities, 
    const std::vector<int> &effects,
    double within_distance_meters) {

    std::vector<std::vector<int>> network(stores.size());
    std::vector<std::tuple<int, int, double>> edges;

    // Match stores with communities within the given radius
    for (size_t i = 0; i < communities.size(); ++i) {
        for (size_t j = 0; j < stores.size(); ++j) {
            if (calculate_distance(communities[i], stores[j]) <= within_distance_meters) {
                network[j].push_back(i);
            }
        }
    }

    // Construct edges between stores sharing communities
    for (size_t i = 0; i < stores.size(); ++i) {
        // iterate over all stores and find the stores that share communities
        for (size_t j = i + 1; j < stores.size(); ++j) {
            // iterate over all adjacent stores and find the shared communities
            double shared_effect = 0;
            for (int community : network[i]) {
                if (std::find(network[j].begin(), network[j].end(), community) != network[j].end()) {
                    // if the community is shared between the two stores
                    shared_effect += effects[community];
                }
            }
            if (shared_effect > 0) {
                double total_effect_i = 0;
                for (int community : network[i]) {
                    total_effect_i += effects[community];
                }
                double total_effect_j = 0;
                for (int community : network[j]) {
                    total_effect_j += effects[community];
                }
                double discount_factor = shared_effect / (total_effect_i * total_effect_j);
                double final_effect = shared_effect * discount_factor;
                edges.emplace_back(i, j, final_effect);
            }
        }
    }

    return {network, edges};
}

PYBIND11_MODULE(network_formulation, m) {
    m.doc() = "Calculate store-community pairs and construct edges with effects";
    m.def("network_formation", &network_formation, 
          "Matches stores with communities, constructs edges with effects, and applies discount factor. Returns the network and edges.");
}