# DeBAM : Decoder based Approximate Multiplier for low power applications

This repository presents the source code for the novel decoder logic-based multiplier (DeBAM) design with the intent to reduce the partial products generated. Thus, leading to a reduction in the hardware complexity and power consumption while maintaining a low error rate.

Our proposed design in an 8-bit format achieves 40.96% and 22.30% power reduction compared to the accurate and approximate unsigned multipliers. Our design is parameterized providing users the flexibility to deploy multipliers of desired bit-width (N) along with the choice of the number of approximate decoder logic blocks implemented ( (N - M)/2 ) to suit application specifications.  

More details about the hardware architecture of DeBAM is available here :
https://ieeexplore.ieee.org/abstract/document/9296261/keywords#keywords

## Contents
### Verilog Design source
Our verilog code has two key parameters N (Multiplier bit-width) and M (Number of Accurate blocks) allowing us to generate the unsigned approximate multipliers of multiple configurations of different bit widths. The parameter M and N can be modified as desired with the following constraints :
- N must be a multiple of 2 (values of N >= 8 have tested)
- M must satisfy the equation (( N-M )/2 >= 3) i.e. the number of approximate Decoder logic blocks must be greater than or equal to 3.
- Some of examples valid configurations for which we have generated hardware metrics are (N.M) -> (8,2) , (16,4) , (16,6) , (16,8)

### Matlab functional Implementation
- A parameterized (N,M) software based Matlab function has been implemented ascertains the expected approximate multiplication output from our proposed multiplier.
- This can be used to ascertain whether the given parameterized implementation is within the error limit for application specific deployment.

This work is based on following article. Please refer them for more detailed description of DeBAM.
1. S. Nambi, U. A. Kumar, K. Radhakrishnan, M. Venkatesan and S. E. Ahmed, "DeBAM: Decoder Based Approximate Multiplier for Low Power Applications," in IEEE Embedded Systems Letters, doi: 10.1109/LES.2020.3045165.
https://ieeexplore.ieee.org/abstract/document/9296261/keywords#keywords

Please refer/cite this papers if you find this work useful for or in your research.
