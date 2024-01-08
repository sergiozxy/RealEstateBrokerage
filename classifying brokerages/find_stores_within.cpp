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

// this function calculates the number of stores within a given distance and records the corresponding labels to be further use.

py::tuple find_stores_within(const std::vector<std::vector<double>> &store_locations, 
                             const std::vector<std::vector<double>> &community_locations, 
                             const std::vector<int> &labels, 
                             double within_distance) {

    std::vector<std::vector<int>> nearest_store_labels(community_locations.size());

    for (size_t i = 0; i < community_locations.size(); ++i) {
        for (size_t j = 0; j < store_locations.size(); ++j) {
            double distance = calculate_distance(community_locations[i], store_locations[j]);
            if (distance <= within_distance) {
                nearest_store_labels[i].push_back(labels[j]);
            }
        }
    }

    return py::make_tuple(nearest_store_labels);
}

PYBIND11_MODULE(find_stores_within, m) {
    m.doc() = "Find the stores within a given distance";
    m.def("find_stores_within", &find_stores_within, "Find the stores within a given distance");
}
