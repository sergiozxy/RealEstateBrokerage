#include <pybind11/pybind11.h>
#include <pybind11/stl.h>
#include <map>
#include <vector>

namespace py = pybind11;

std::vector<double> calculate_HHI(const std::vector<std::vector<int>>& data) {

    std::vector<double> HHI_indices;
    for (const auto& row : data) {
        std::map<int, int> frequency;
        int totalMarketShare = 0;
        int independentCount = 0; // total number of independent real estate brokerages in given segment
        double HHI = 0;

        for(int num: row){
            if(num != -1){
                frequency[num]++;
                totalMarketShare += 1;
            }
            else{
                independentCount++;
                totalMarketShare += 1;
            }
        }

        for(const auto& [key, count]: frequency){
            double sharePercentage = static_cast<double>(count) / totalMarketShare;
            HHI += sharePercentage * sharePercentage;
        }

        HHI += static_cast<double>(independentCount) / totalMarketShare / totalMarketShare;
        HHI_indices.push_back(HHI);
    }

    return HHI_indices;
}

PYBIND11_MODULE(hhi_calculator, m) {
    m.doc() = "Pybind11 example plugin"; // Optional module docstring

    m.def("calculate_HHI", &calculate_HHI, "A function which calculates the HHI");
}