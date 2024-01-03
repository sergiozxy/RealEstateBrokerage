#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <vector>
#include <cmath> // Include the cmath library for math operations
#include <limits> // Include the limits library for numeric_limits

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

py::tuple find_nearest_communities(const std::vector<std::vector<double>> &store_locations, const std::vector<std::vector<double>> &community_locations, int num_nearest_communities) {
    std::vector<std::vector<int>> nearest_community_indices;
    std::vector<std::vector<double>> nearest_community_distances;

    for (const auto &store_location : store_locations) {
        std::vector<int> nearest_indices;
        std::vector<double> nearest_distances;
        std::vector<bool> is_community_selected(community_locations.size(), false);

        for (int i = 0; i < num_nearest_communities; ++i) {
            double min_distance = std::numeric_limits<double>::max();
            int nearest_index = -1;

            for (size_t j = 0; j < community_locations.size(); ++j) {
                if (!is_community_selected[j]) {
                    double distance = calculate_distance(store_location, community_locations[j]);

                    if (distance < min_distance) {
                        min_distance = distance;
                        nearest_index = static_cast<int>(j);
                    }
                }
            }

            if (nearest_index != -1) {
                nearest_indices.push_back(nearest_index);
                nearest_distances.push_back(min_distance);
                is_community_selected[nearest_index] = true;
            }
        }

        nearest_community_indices.push_back(nearest_indices);
        nearest_community_distances.push_back(nearest_distances);
    }

    return py::make_tuple(nearest_community_indices, nearest_community_distances);
}

PYBIND11_MODULE(nearest_community_cpp, m) {
    m.doc() = "Nearest Community Calculation";
    m.def("find_nearest_communities", &find_nearest_communities, "Find nearest communities");
}

