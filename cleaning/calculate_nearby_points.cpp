#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <vector>
#include <cmath>

namespace py = pybind11;

double calculate_distance(const std::vector<double> &point1, const std::vector<double> &point2) {
    const double earth_radius_km = 6371.0;
    const double deg_to_rad = M_PI / 180.0;

    double lat1_rad = point1[1] * deg_to_rad;
    double lon1_rad = point1[0] * deg_to_rad;
    double lat2_rad = point2[1] * deg_to_rad;
    double lon2_rad = point2[0] * deg_to_rad;

    double dlon = lon2_rad - lon1_rad;
    double dlat = lat2_rad - lat1_rad;
    double a = std::sin(dlat/2) * std::sin(dlat/2) + std::cos(lat1_rad) * std::cos(lat2_rad) * std::sin(dlon/2) * std::sin(dlon/2);
    double c = 2 * std::atan2(std::sqrt(a), std::sqrt(1-a));
    double distance_km = earth_radius_km * c;

    return distance_km * 1000; // Convert to meters
}

std::vector<int> calculate_counts(const std::vector<std::vector<double>> &array1, 
                                         const std::vector<std::vector<double>> &array2, 
                                         double within_distance_meters) {
    std::vector<int> counts(array1.size(), 0);

    for (size_t i = 0; i < array1.size(); ++i) {
        for (size_t j = 0; j < array2.size(); ++j) {
            if (calculate_distance(array1[i], array2[j]) <= within_distance_meters) {
                counts[i]++;
            }
        }
    }

    return counts;
}

PYBIND11_MODULE(calculate_nearby_points, m) {
    m.doc() = "Calculate number of points within a given distance";
    m.def("calculate_counts", &calculate_counts, 
          "Calculates for each point in array1 the count of points in array2 within a specified distance in meters.");
}
