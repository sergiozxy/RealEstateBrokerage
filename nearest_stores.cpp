#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <vector>
#include <cmath>
#include <limits>
#include <queue>

namespace py = pybind11;

// Function to calculate geographical distance between two points (km)
double calculate_distance(const std::vector<double> &point1, const std::vector<double> &point2) {
    const double earth_radius_km = 6371.0; // Earth's radius in kilometers

    // Convert latitude and longitude from degrees to radians
    double lat1_rad = point1[1] * M_PI / 180.0;
    double lon1_rad = point1[0] * M_PI / 180.0;
    double lat2_rad = point2[1] * M_PI / 180.0;
    double lon2_rad = point2[0] * M_PI / 180.0;

    // Haversine formula
    double dlon = lon2_rad - lon1_rad;
    double dlat = lat2_rad - lat1_rad;
    double a = std::sin(dlat/2) * std::sin(dlat/2) + std::cos(lat1_rad) * std::cos(lat2_rad) * std::sin(dlon/2) * std::sin(dlon/2);
    double c = 2 * std::atan2(std::sqrt(a), std::sqrt(1-a));
    double distance_km = earth_radius_km * c;

    return distance_km;
}

py::tuple find_nearest_stores_to_communities(const std::vector<std::vector<double>> &store_locations, const std::vector<std::vector<double>> &community_locations, int num_nearest_stores) {
    std::vector<std::vector<int>> nearest_store_indices(community_locations.size());
    std::vector<std::vector<double>> nearest_store_distances(community_locations.size());

    for (size_t i = 0; i < community_locations.size(); ++i) {
        // Using a min heap to store the nearest stores
        std::priority_queue<std::pair<double, int>, std::vector<std::pair<double, int>>, std::greater<std::pair<double, int>>> min_heap;

        for (size_t j = 0; j < store_locations.size(); ++j) {
            double distance = calculate_distance(community_locations[i], store_locations[j]);
            min_heap.emplace(distance, j);
        }

        for (int k = 0; k < num_nearest_stores && !min_heap.empty(); ++k) {
            nearest_store_indices[i].push_back(min_heap.top().second);
            nearest_store_distances[i].push_back(min_heap.top().first);
            min_heap.pop();
        }
    }

    return py::make_tuple(nearest_store_indices, nearest_store_distances);
}

PYBIND11_MODULE(nearest_stores, m) {
    m.doc() = "Nearest Store Calculation for Communities";
    m.def("find_nearest_stores_to_communities", &find_nearest_stores_to_communities, "Find nearest stores to communities");
}