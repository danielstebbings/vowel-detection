#import "@preview/charged-ieee:0.1.4": ieee

// Acronyms
#import "@preview/acrostiche:0.5.1": *

#init-acronyms((
  "STAC": "Spacecraft Tracking & Command Station",
  "VHF": "Very High Frequency",
  "UHF": "Ultra High Frequency",
  "FE": "Front End",
  "LVDS": "Low Voltage Differential Signalling",
  "DVB-S2": "Digital Video Broadcasting - Satellite - Second Generation",
  "ACM": "Adaptive Coding and Modulation",
  "TS": "Transport Stream",
  "XTCE": "XML Telemetric and Command Exchange",
  "SDR": "Software Defined Radio",
  "UPL": "User Packet Length",
  "DFL": "Data Field Length",
  "BBFRAME": "Baseband Frame",
  "IQ": "In-phase and Quadrature",
  "SPI": "Serial Peripheral Interface",
  "PBR": "Passive Bistatic Radar",
  "ISS": "International Space Station",
  "COTS": "Commercial Off-The-Shelf",
  "BCH": "Bose-Chaudhuri-Hocquenghem",
  "LDPC": "Low-Density Parity-Check",
  "FECFRAME": "Forward Error Correction Frame",
  "PLFRAME": "Physical Layer Frame",
  "FEC": "Forward Error Correction",
  "SNR": "Signal to Noise Ratio",
  "CNR": "Carrier to Noise Ratio",
  "ITU": "International Telecommunication Union",
  "PS": "Processing System",
  "PL": "Programmable Logic",
  "CCSDS": "Consultative Committee for Space Data Systems",
  "ESA": "European Space Agency",
  "FYS": "Fly Your Satellite",
  "RF": "Radio Frequency",
  "CCDD": "Core Flight System (CFS) Command and Data Dictionary",
  "IPC": "Inter-Process Communication",
  "ISM": "Industrial, Scientific, and Medical",
  "SoC": "System on Chip",
  "CRC-8": "8 bit Cyclic Redundancy Check",
  "GSE": "Generic Stream Encapsulation",
  "FIFO": "First In First Out",
  "I2C": "Inter-Integrated Circuit",
  "CAN": "Controller Area Network",
  "IP": "Internet Protocol",
  "PDR": "Preliminary Design Review",
  "BER": "Bit Error Rate",
  "FPGA": "Field Programmable Gate Array",
  "ADC": "Analog to Digital Converter",
  "DAC": "Digital to Analog Converter",
  "ETSI": "European Telecommunications Standards Institute",
  "VCM": "Variable Coding and Modulation",
  "VL-SNR": "Very Low Signal-to-Noise Ratio",
  "BPSK": "Binary Phase Shift Keying",
  "PDU": "Protocol Data Unit",
  "AWGN": "Additive White Gaussian Noise",
  "RTL": "Register Transfer Level",
  "TT&C": "Telemetry, Tracking and Command",
  "CCM": "Constant Coding and Modulation",
  "EDHPC": "European Data Handling & Data Processing Conference",
  "TBC": "To Be Confirmed",
  "OBC": "On Board Computer",
  "EIRP": "Effective Isotropic Radiated Power",
  "RAM": "Random Access Memory",
  "FMC": "FPGA Mezzanine Card",
  "BBHEADER": "Base Band Header",
  "APSK": "Amplitude and Phase Shift Keying",
  "MATYPE": "Mode Adaption Type",
  "MODCOD": "MODulation and CODing rate",
  "TLE": "Two-Line Element set",
  "UART": "Universal Asynchronous Receiver-Transmitter",
  "MSB": "Most Significant Bit",
  "LSB": "Least Significant Bit",
  "FSPL": "Free Space Path Loss",
  "LUT": "Look Up Table",
  "VSWR": "Voltage Standing Wave Ratio",
))

#show: ieee.with(
  title: [Analysis and Implementation of DVB-S2 in the UHF Band for STRATHcube Downlink Communications ],
  abstract: [
    This paper outlines the downlink system design for STRATHcube, a student-led CubeSat project at the University of Strathclyde. Performance and link analyses were conducted, analysing communication windows over the course of the mission and expected theoretical performance. The design was implemented in hardware using MathWorks HDL Coder and initial code developed for packet handling in software.

    Initial performance analysis was conducted in comparison to a reference implementation which uses Constant Coding and Modulation (CCM) and optimises for maximum availability. Our CubeSat downlink design showed a significant uplift in performance over the course of the mission compared to the reference, achieving 3.19#sym.times the data throughput. Additionally, resource analysis of the target FPGA SoC and the implemented design, as well as timing analysis, show that the system will be implementable in hardware.
  ],
  authors: (
    (
      name: "Daniel Stebbings†*, Louise Crockett†, Carmine Clemente†, and Massimiliano Vasile‡",
      department: [†Department of Electronic and Electrical Engineering ‡Department of Mechanical and Aerospace Engineering],
      organization: [University of Strathclyde],
      location: [Glasgow, Scotland, UK],
      email: "Email: *danielastebbings@gmail.com",
    ),

  ),
  index-terms: ("CubeSat", "Communications", "DVB-S2", "Software Defined Radio"),
  bibliography: bibliography((
    "./Bibliographies/Link-Budget.bib",
    "./Bibliographies/DVB-S2.bib",
    "./Bibliographies/Hardware.bib",
    "./Bibliographies/Implementation.bib",
    "./Bibliographies/Packets.bib",
    "./Bibliographies/STRATHcube.bib",
  )),
  figure-supplement: [Fig.],
)

= Introduction <sec:Introduction>

== CubeSat Communications

Efficient downlink of data is a critical challenge in CubeSat missions, as they are highly constrained in power, bandwidth, and by the dynamic channel conditions imposed during a ground station pass. These issues are further exacerbated in the commonly used #acr("UHF") amateur allocation due to in-band interference and further bandwidth constraints.

There are several dynamic factors inherent in satellite to ground communications, including pointing losses, total slant range and scintillation effects. Some of these factors can be known in advance, however others such as interference are difficult to predict and have an outsized impact on error rates. For this reason systems with #acr("ACM") can improve link availability and spectral efficiency compared to #acr("CCM"), or those that change based on predicted values but without real time adaptation, #acr("VCM"), however this does come at the cost of increased complexity.

#acr("DVB-S2") is one such #acr("ACM") system, with near Shannon limit performance and a modular standard allowing it to be matched to the usecase. Despite this, it has not seen common use in the #acr("UHF") band for CubeSats as it typically requires complex and expensive #acr("SDR") based hardware with higher power draw. However, STRATHcube will already include such hardware for its primary payload, presenting an opportunity for increased downlink capability for minimal added cost.

A similar system is described in @grayver_software_2015, which details a Zynq 7020 #acr("FPGA") #acr("SoC") SDR-based communication platform operating in the 915 MHz UHF band and utilising ACM. The system used similar modulation to DVB-S2 but with a different
coding method, turbo coding instead of the concatenated #acr("BCH") and #acr("LDPC") codes used in DVB-S2. Their analysis showed a near doubling in throughput compared to CCM. This proved that ACM systems
for CubeSats are feasible and could offer large performance benefits. 

// TODO: Comparison between them and strathcube
The system presented in @grayver_software_2015 was found to have a notably high power consumption during transmission of 8.8 W, however it was argued that this was offset by the short length of ground station passes. 

The system presented in @grayver_software_2015 used a bandwidth of 1 MHz and analysed an orbit of 800 km, substantially higher than the 25 kHz and 425 km of STRATHcube. However, the reported #acr("SNR") range of -1 dB to 13 dB is very similar to the #acr("SNR") range expected for STRATHcube of -1.24 dB to 14.28 dB identified in @sec:acm_anal, which indicates that the comparison is valid despite the differences in system parameters.

== The STRATHcube Mission

STRATHcube is a 2U CubeSat in development at the University of Strathclyde and part of the _ESA Fly Your Satellite! Design Booster_ program @european_space_agency_fly_nodate. It has two payloads, each targeting a key area of space sustainability.

The primary payload is a technology demonstrator of a Passive Bistatic Radar (PBR) for the detection of space debris using an SDR as discussed in @persico_cubesat-based_2019. The satellite will record IQ data for analysis on the ground. Although compressed, this will be a considerable data volume therefore the downlink data rate will be one of the primary bottlenecks for its operation. Consequently, there will already be a powerful #acr("FPGA") based SDR included on the mission, the Alén Space TOTEM SDR, which would allow a DVB-S2 transmitter to be implemented as a "piggy-back" on the primary payload using spare resources.

The secondary payload aims to measure the aerothermal effects leading to solar panel fragmentation  by recording and transmitting sensor data during the moments up to re-entry. This is unlikely to occur near a ground station and instead a secondary transceiver is to be used that communicates via the Iridium network.

The #acr("STAC") based at the University of Strathclyde is the current planned ground station for the mission. It is equipped with two circularly polarised #acr("UHF") antennas from M#super("2") Antenna Systems Inc @m2_antenna_systems_inc_436cp30_2017, an SP-7000 pre-amplifier from SSB Electronic and an Ettus Research B210 #acr("SDR") for reception. The station has been out of use for some time, so rated performance values may not match the current state of the hardware.

== Mission Phases

The mission shall be split into four distinct operational phases starting with deployement from the #acr("ISS") and ending with the demise of the satellite.

+ Early Operations and Commissioning (\~10 days): Deployment from the #acr("ISS") and system activation.
+ Primary Operations (\~170 days): Alternating PBR measurements and data downlink during ground station windows until altitude trigger (\~170km).
+ Transition Phase: Reconfiguration for re-entry. Involves transition to communications primarily via the Iridium network.
+ Secondary Phase: Re-entry data collection and downlink until demise.

The #acr("UHF") downlink communications will occur during the first three phases, driving subsequent analysis.

== Objectives
// TODO: Improve objectives
This work focused on the development of STRATHcube's downlink communications system design, with objectives to:
+ Develop a comprehensive link budget for the STRATHcube downlink communications to identify relevant design parameters.
+ Develop a detailed system architecture leveraging both the processing system and programmable logic of the target Zynq device.
+ Develop an engineering model targeting development boards that were representative of planned flight hardware.

The scope was limited to exclude the uplink design, with deployment onto hardware as an optional goal. Due to this, the system was designed to be modular to facilitate future development.

= Adaptive Coding and Modulation Analysis <sec:acm_anal>

== Link Budget Analysis <sec:link_budget>

A new link budget was created to identify the received #acr("SNR") at each time step during the pass. Parameters were divided into _static_, those that would not change during a pass, and _dynamic_, those that would, as shown by @tab:static_link_params and @tab:dynamic_link_params.

#figure(
  table(
    columns: (auto, auto, auto),

    align: (left, center, center),
    table.header([*Name*], [*Value*], [*Description*]),
    table.cell(colspan: 3, align(center, strong("System"))),
    [Frequency ($f$)], [437 MHz], [Centre of UHF Amateur Satellite Service Allocation],
    [Bandwidth ($B$)], [25 kHz], [Commonly allocated bandwidth],
    [Target Margin], [3 dB], [Standard margin target],

    table.cell(colspan: 3, align(center, strong("STRATHcube"))),
    [Transmit Power ($P_"Tx"$)], [$1 "W"$ ($0 "dBW"$)], [TOTEM UHF FE Limit, @alen_space_frontenduhf_2021],
    [Cable Losses ($L_"Cable"$)], [$0.116 "dB"$], [20cm RG-188/AU],
    // Big margin, AcubeSAT calc
    [Antenna #acr("VSWR")], [$1.9:1$], [ISIS Antenna Datasheet @isispace_cubesat_nodate],
    // ISIS ant datasheet
    [Antenna Matching Loss ($L_"Matching"$)], [$0.44 "dB"$], [@eq:Reflection_Loss],
    [Connector Losses ($L_"Connector"$)], [$0.2 "dB"$], [4 Connectors \@ 0.05dB, Estimation],
    [Switch Losses ($L_"Switch"$)], [$0.5 "dB"$], [Estimation],
    //AcubeSAT, unsure if real
    [Transmit Antenna Gain ($G_"Tx"$)], [$0 "dBi"$], [ISIS Antenna Datasheet @isispace_cubesat_nodate],
    [*#acr("EIRP")*], [*$-1.26 "dBW"$*], [@eq:EIRP],

    table.cell(colspan: 3, align(center, strong("Ground Station"))),
    [Receive Antenna Gain ($G_"Rx"$)], [$15.5 "dBic"$], [STAC UHF Antenna @m2_antenna_systems_inc_436cp30_2017],
    [Polarisation Loss ($L_"Pol"$)], [$3 "dB"$], [Linear to circular],
    [Pointing Loss ($L_"Point"$)], [$1 "dB"$], [Estimation],
    [Preamplifier Gain ($G_"Preamp"$)], [$20 "dB"$], [SP-7000 Datasheet @ssb_sp-7000_2012 ],
    [Preamplifier Noise Figure ($F_"Preamp"$)], [$0.9 "dB"$], [SP-7000 Datasheet @ssb_sp-7000_2012 ],
    [Line Losses], [$5.47 "dB"$], [36m of RG213],
    [Receive SDR Noise Figure ($F_"SDR"$)], [$8 "dB"$], [Ettus Research B210 Datasheet @ettus_research_b210_nodate],
    [Terrestrial Noise Figure ($F_"T"$)],
    [$6 "dB rel. "k T_0 B$],
    [Outdoor manmade noise in city at 425 MHz @noauthor_radio_2016[Tab. 3]],
    [Terrestrial Noise Power ($P_"T"$)], [$-154.0 "dBW"$], [@eq:noise_power],
  ),
  caption: "Static Link Parameters",
) <tab:static_link_params>

#figure(
  table(
    columns: (auto, auto, auto),

    align: (left, center, center),
    table.header([*Name*], [*Values*], [*Description*]),
    [Elevation], [$10° "to" 40°$], [10° threshold to be counted as pass, 40° max elevation found through simulation ],
    [Altitude], [$170 "km" "to" 425 "km"$], [Deployment altitude from ISS to transition altitude trigger],
    [Slant Range (SR)],
    [$260 "km" "(40° @ 170km)" \ "to" \ 1505 "km" "(10° @ 425km)"$],
    [MATLAB function @mathworks_matlab_nodate],

    [#acr("FSPL")], [$133.5 "dB" "(260km)" \ "to" \ 148.8 "dB" "(1550km)"$], [@eq:FSPL],
    [Atmospheric Losses (AL)],
    [$0.074 "dB" "(40°)" \ "to" \ 0.318 "dB" "(10°)"$],
    [Includes gaseous, scintillation, cloud and rain losses. Calculated using atmospheric models with  ITU-Rpy @portillo_itu-rpy_2017],
  ),
  caption: "Dynamic Link Parameters",
) <tab:dynamic_link_params>


$ Γ = ("VSWR"-1) / ("VSWR"+1) $
$ L_"Matching,dB" = 10 log_10 (1- Γ^2) ["dB"] $ <eq:Reflection_Loss>


$
  "EIRP"_"dB" = 10 log_10 (P_"Tx,W") - L_"Line,dB" - L_"Switch,dB"
  #linebreak()
  - L_"Matching,dB" + G_"Tx,dB" ["dBW"]
$ <eq:EIRP>


$ "P"_"T,dB" = F_"T" + 10 log_10 (k T_0 B) $ <eq:noise_power>

Free Space Path Loss: @sklar_digital_2009[eq. 5.10]
$ "FSPL" = 20 log_10 ((4 pi d f)/ (c)) ["dB"] $ <eq:FSPL>

Where $k = 1.38 times 10^(-23) "J/K"$ is the Boltzmann constant and $T_0 = 290 "K"$ is the reference temperature.

The final received signal power can be calculated the #acr("EIRP") less all losses and the received noise power as the terrestrial noise power with amplification from the preamp and including the noise figure of each element of the receive chain.

$
  P_"Rx,dB" = "EIRP"_"dB" - "FSPL"_"dB" - "AL"_"dB" - L_"Pol,dB"
  #linebreak()
  -L_"Point,dB" + G_"Rx,dB" + G_"Preamp,dB"
  #linebreak()
  - L_"Line,dB" ["dBW"]
$

$
  P_"N,dB" = P_"T,dB" + G_"Preamp,dB" + F_"Preamp,dB"
  #linebreak()
  + F_"SDR,dB" ["dBW"]
$

Therefore the #acr("SNR") of the received signal is simply:

$ "SNR" = P_"Rx,dB" - P_"N,dB" ["dB"] $

#acr("DVB-S2") uses #acr("APSK") modulation, from QPSK to 32APSK and coding rates from 1/4 to 9/10. Further modulation and coding options were added with DVB-S2X to support an even wider SNR range, although these were not considered during this investigation. Additionally, there are two options for the frame length, normal and short, and pilots can be optionally inserted to improve receiver performance.

The minimum #acr("SNR") required was taken from @etsi_en_2014[Tab. 13] which assumed a normal frame length, no pilots, 50 #acr("LDPC") decoding iterations, perfect carrier and synchronisation recovery, no phase noise, and #acr("AWGN").

Interference is likely to be present in this band due to amateur radio users, spurious emissions and other sources. Further,  phase noise will likely be induced due to multipath and atmospheric effects. The calculated margin will therefore be optimistic compared to the practical system. To offset this, when calculating data rate the reduced spectral efficiency for a system with pilots was used from @ccsds_ccsds_2023.

The link budget and margin for an adverse and a favourable scenario is shown in @tab:budget, with the optimal modulation and coding rate selected to meet the 3dB margin requirement. The data rate was calculated directly from the spectral efficiency and bandwidth using @eq:spect_eff_2_cap.

$ "Data Rate" = #sym.eta times B ["bps"] $ <eq:spect_eff_2_cap>

#figure(
  table(
    columns: 3,
    inset: 6pt,
    align: (horizon, horizon, horizon),
    table.header([*Parameter*], [*Adverse*], [*Favourable*]),

    [Elevation], [$10 #sym.degree$], [$40 #sym.degree$],
    [Altitude], [$425 "km"$], [$170 "km"$],
    [Noise Power], table.cell(colspan: 2, align(center, $-125.1 "dBW"$)),
    [Received Signal Power], [$-123.2 "dBW"$], [$-107.7 "dBW"$],
    [SNR], [$1.9 "dB"$], [$17.4 "dB"$],
    [Optimal Modulation and Coding Rate], [$"QPSK" 1/3$], [$"32APSK" 5/6$],
    [Required SNR], [$-1.24 "dB"$], [$14.28 "dB"$],
    [Margin], [$3.14 "dB"$], [$3.12 "dB"$],
    [Spectral Efficiency], [$0.6408 "bit/s/Hz"$], [$4.0306 "bit/s/Hz"$],
    [Data Rate], [$16.020 "kb/s"$], [$100.76 "kb/s"$],
  ),
  caption: "Link Budget",
) <tab:budget>

== Adaptive vs Constant

Proof-of-concept analysis was conducted to assess if the performance gains offered by #acr("ACM") justify the increased complexity. A simulation of the orbit was used to identify the elevation angle and satellite altitude during pass opportunities over the #acr("STAC") for the full duration of the mission.

Due to the location of the ground station at 55.862°N, 4.245°W, the observed elevations did not rise above 40#sym.degree, as shown in @img:elev_times. The majority of passes occured in the range of 10#sym.degree to 20#sym.degree. The corresponding optimal modulation and coding rates and data rates are shown in @img:elev2modcod.

For reference, the data rate for a #acr("CCM") #acr("DVB-S2") system was selected to maximised availability, in this case using QPSK 1/3 for the duration of the mission. The #acr("ACM") system was assumed to take the optimal setting for each 10 second timestep of the simulation.
#place(
    top+center,
    float: true,
    scope: "parent"
    )[
#figure(
  image("FIgures/elevation_vs_modcod.png",width:auto),
  caption: "Optimal MODulation and CODing (MODCOD) rate by elevation and altitude.",
)<img:elev2modcod>
    ]
#figure(
  image("FIgures/Altitude_vs_time.svg"),
  caption: "STRATHcube altitude from deployment to mode transition.",
)<img:alt_vs_time>

#figure(
  image("FIgures/Elevation_Time.svg"),
  caption: "STRATHcube time spent at elevation over STAC.",
)<img:elev_times>



#colbreak()
@tab:total_data shows the total data downlinked by each strategy over the full duration of the mission. The adaptive system was able to downlink 3.19#sym.times the amount of data versus the constant system, indicating that the increased system complexity is outweighed by the improved performance.

#figure(
  table(
    columns: 2,
    inset: 6pt,
    align: (horizon, horizon),
    table.header([*Strategy*], [*Total Data Downlinked (Gb) *]),
    [Constant], [1.88],
    [Adaptive], [6.01],
  ),
  caption: "Total Data Downlinked by Strategy",
) <tab:total_data>

== Areas for Further Investigation

// TODO: ROLLOFF
The presented link budget  was developed to show the viability of an adaptive DVB-S2 system and as such there was comparatively less investigation of the ground station receiver system. The implementation of the receiver will be challenging, and require further investigation of the in-band interference present at the site. Should the margin decrease, the expanded modulation and coding options in DVB-S2X for very low #acr("SNR") applications could be used.
Additionally, the bandwidth calculations did not account for filter roll-off, this is discussed further in @sec:implementation.

= Transmitter Design and Implementation

== Design
Following the ACM analysis, it was decided to implement a DVB-S2 compliant system with ACM capabilities. As flight hardware could not be sourced for this investigation, the target platform was a combination of a Digilent ZedBoard Zynq 7020 development board @noauthor_zedboard_nodate-1 attached to an Analog Devices AD-FMCOMMS4 AD9364 evaluation board @noauthor_ad-fmcomms4-ebz_nodate. As the interface of the AD936x series transceivers are the same, the system could be verified with a different transceiver in the same family.

The designed system had a modular structure, allowing unit testing of each component and facilitating changes in the future as the satellite is developed further.

#list(
  [*Processing System (PS)*:
    #list(
      [*System Interface*: Aggregate packets from all external input sources.],
      [*Packet Parser*: Inspect the input packets to determine their priority level.],
      [*ACM Router*: Assign packets into buffers according to Quality of Service (QoS) requirements and encapsulation using Generic Stream Encapsulation (GSE) for efficient framing.],
      [*PS-PL Interface*: Break up packets for transfer using an Advanced eXtensible Interface (AXI) Stream and manage control signals for the DVB-S2 Transmitter system.]
    )
  ],
  [*Programmable Logic (PL)*:
    #list(
      [*DVB-S2 Interface*: Manage interface from DVB-S2 transmitter block to PS AXI-Stream interface.],
      [*DVB-S2 Transmitter*: Manages framing, coding, modulation and filtering at baseband.],
      [*AD936x Controller*: Manages interface with transceiver.]
    )
  ],
  [*External Hardware*:
    #list(
      [*AD9364 Transceiver*: Upconversion and transmission of signal.]
    )
  ]
)

== Implementation <sec:implementation>

The FPGA implementation was developed using MathWorks HDL Coder @inc_hdl_2024 due to ease of implementation and ease of testing. Further, using the _Hardware Software Codesign_ @the_mathworks_hardware-software_2024 methodology, both the transceiver interface and PS-PL interface bindings could be automatically generated.

A reference DVB-S2 HDL Coder implementation by MathWorks @mathworks_dvb-s2_2024 was selected to reduce technical risk, as it was pre-tested, allowing faster development of the rest of the system. Further logic was added around this block to manage the AXI-Stream interface and to convert the output for the 12-bit DAC interface. The transmitter portion is shown in @img:hdlcoder-imp. The roll-off factor was selected as 0.25 to balance throughput with filter complexity and resulted in a symbol rate of 20,000 symbols / second.

The implementation of packet handling is yet to be completed, although relevant libraries have been identified and work begun on a C++ implementation of GSE. Further, the packet handling system shall be designed to work with schemas for packet definition to reduce the difficulty of modification as the satellite design is updated. 

#place(
    top+center,
    float: true,
    scope: "parent"
    )[
#figure(
  image("FIgures/Annotated-Tx.drawio.png"),
  caption: "Block diagram of HDL Coder implementation. Highlighted in cyan is the transmitter block created by MathWorks. Highlighted in green are the implemented blocks for communication with the processing system.",
) <img:hdlcoder-imp>
    ]
    
== Results & Discussion

MATLAB code was created to generate synthetic AXI packets to test the system in Simulink. The resulting output spectrum was shown to pass against the #acr("ITU") out-of-band emissions mask for the amateur and amateur satellite service @noauthor_unwanted_2024[Fig. 43] as shown in @img:spectrum. 
#figure(
  image("FIgures/pspect.png"),
  caption: "Power spectrum at transmitter output. Note that the power scale is not representative of the actual peak output power. The shaded area shows the ITU emission mask that the signal should remain below, where green indicates passing."
) <img:spectrum>

The resource utilisation of the implemented programmable logic design is shown by subsystem and resource type in @img:util and @tab:util. This design is intended to be expanded in the future to include the payload signal processing, as well as the receive chain, therefore, excessive resource usage could cause issues. 

Overall, the highest resource usage was in the Block RAM, where this design used 89% of those available. Block RAM was used for three buffers within the design, 24 for the implemented interfacing logic, a further 25 for the frame during error correction, and 75.5 for the physical layer framing. The high usage is primarily due to the entire frame being stored at once at each stage. Optimisations could be made if the frames were stored and generated in chunks, perhaps at a higher clock speed to ensure that the output does not stall.

The other resource usage rates were deemed acceptable, the multiplexer and DSP48 tile usage being particularly low and unlikely to impact further designs, however, the slice #acr("LUT") usage is quite high overall with only 34.9% free.

#figure(
  image("FIgures/util.png"),
  caption: "Percentage utilisation by resource type and subsystem. The DVB-S2 transmitter is shown in pink, the interface linking the processing system and programmable logic in blue, and the transceiver controller in green."
) <img:util>

Timing analysis found a worst negative slack of 0.126 ns, a worst hold slack of 0.016 ns and a worst pulse width slack of 0.264 ns at 61.44 MHz. Although the design met timing, the large chip area used due to high Block RAM utilisation could cause issues if higher clock speeds are required in the future. 

The Vivado power analysis tool was used to estimate the efficiency of the final design. The tool was used in maximum usage mode. A range of default toggle rates were used to identify the expected power draw of the design based on its activity level, as shown in @tab:power. The reported figures do not include the expected power required for the transceiver, or power amplifier components. These are early stage measurements and specific power optimisations have not been implemented yet. Further optimisation and measurement of the implemented system on hardware is required. 

#figure(
  table(
    columns: (auto, auto),
    align: (center, center),
    table.header([*Default Toggle Rate (%)*], [*Estimated Power Consumption (W)*]),
    [12.5], [3.286],
    [25], [3.398],
    [50], [3.614],
    [75], [3.823],
    [100], [4.009],
  ),
  caption: "Transmitter design power consumption by default toggle rate. ",
) <tab:power>


#place(
    top+center,
    float: true,
    scope: "parent"
    )[
#figure(
  table(
    columns: (auto,auto,auto,auto,auto,auto,auto,auto),
    align: (center, center, center, center, center, center, center),
    table.header(
      [*Name*], [*AD9364 Transceiver*], [*PS-PL Interface*], [*Other*], [*DVB-S2 Transmitter*], [*Total Used*], [*Available*], [*Usage (%)*]
    ),
    [Slice LUTs], [11353], [11032], [98], [12151], [34634], [53200], [65.10],
    [Slice Registers], [16467], [14671], [244], [10074], [41456], [106400], [38.96],
    [F7 Muxes], [78], [158], [0], [1591], [1827], [26600], [6.87],
    [F8 Muxes], [16], [71], [0], [12], [99], [13300], [0.74],
    [Block RAM], [4], [0], [0], [125], [129], [140], [92.14],
    [DSP48], [28], [0], [0], [42], [70], [220], [31.82],
  ),
  caption: "FPGA resource utilisation by subsystem and resource type."
) <tab:util>]





= Conclusions and Further Work

The performance of a DVB-S2 #acr("ACM") system was analysed for the STRATHcube mission and found to offer substantial performance benefits, although with a noted added complexity. 
A transmitter was developed and simulated building upon a MathWorks HDL Coder implementation. This design was then synthesised using Vivado and found to meet timing constraints.

The system is still to be tested in hardware and the packet handling software is still under development. The link calculations were made using several assumptions about the ground station receiver and will be revised when measurements can be made which may impact the transmitter design requirements. Investigation into interference and the development of the receiver is of particular importance.

= Acknowledgements

Thanks are given to the sponsors of the STRATHcube, without whom this project would not be possible: ESA Academy, The University of Strathclyde Alumni Fund,
the Institute of Mechanical Engineers, the Royal Aeronautical Society, the University
of Strathclyde Mechanical and Aerospace Engineering Department, and the University
of Strathclyde Aerospace Centre of Excellence.