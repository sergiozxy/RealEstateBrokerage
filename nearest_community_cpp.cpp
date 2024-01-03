#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <vector>
#include <cmath> // Include the cmath library for math operations

namespace py = pybind11;

// Function to calculate Euclidean distance between two points
double calculate_distance(const std::vector<double> &point1, const std::vector<double> &point2) {
    double sum = 0.0;
    for (size_t i = 0; i < point1.size(); ++i) {
        double diff = point1[i] - point2[i];
        sum += diff * diff;
    }
    return std::sqrt(sum);
}

std::vector<std::vector<int>> find_nearest_communities(const std::vector<std::vector<double>> &store_locations, const std::vector<std::vector<double>> &community_locations, int num_nearest_communities) {
    std::vector<std::vector<int>> nearest_community_indices;

    for (const auto &store_location : store_locations) {
        std::vector<int> nearest_indices;
        for (size_t i = 0; i < num_nearest_communities; ++i) {
            double min_distance = std::numeric_limits<double>::max(); // Initialize with a large value
            int nearest_index = -1;
            for (size_t j = 0; j < community_locations.size(); ++j) {
                // Calculate the distance between the store and community
                double distance = calculate_distance(store_location, community_locations[j]);
                if (distance < min_distance) {
                    min_distance = distance;
                    nearest_index = static_cast<int>(j);
                }
            }
            if (nearest_index != -1) {
                nearest_indices.push_back(nearest_index);
            }
        }
        nearest_community_indices.push_back(nearest_indices);
    }

    return nearest_community_indices;
}

PYBIND11_MODULE(nearest_community_cpp, m) {
    m.doc() = "Nearest Community Calculation";
    m.def("find_nearest_communities", &find_nearest_communities, "Find nearest communities");
}

