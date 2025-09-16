# AI GPU Grid – Scalable GPU Interconnects with AXI & NoC

**AI GPU Grid** implements a scalable **Network-on-Chip (NoC)** architecture to interconnect multiple GPUs using the **AXI protocol**. The NoC consists of **8 groups**, each with **4 leaf routers** and **4 spine routers**, supporting **32 GPUs** in total. The design is modular, enabling efficient, high-speed communication and scalable expansion.

Each **leaf router** connects one GPU via a **Network Interface (NI)** and four spine routers within its group. Leaf routers have FIFOs for buffering, ports for interfacing, and a crossbar switch for arbitration, with both fixed-priority and round-robin schemes to ensure fair handling of GPU traffic. **Spine routers** form the backbone of the Dragonfly+ topology, connecting leaf routers within the group and corresponding spine routers across other groups. Each spine router is controlled by an FSM that monitors incoming packets, consults routing logic, and forwards packets while checking FIFO status to prevent overflow.

Communication between GPUs uses the **AXI protocol**, supporting high-performance, bidirectional master-slave transactions. To validate GPU functionality, simplified AXI testbenches were implemented before full integration, ensuring that each GPU could generate and respond to AXI transactions correctly.

Routers employ **synchronous FIFO buffers** implemented as circular queues with independent read/write pointers, full/empty flags, and configurable depth/width. **Dedicated router ports** were developed as modular interfaces with input/output FIFOs, valid/ready signaling, and direction control, allowing burst traffic handling while preserving order and preventing packet loss. This modular structure simplifies flow control and supports scalable router designs.

The repository includes the **top-level NoC module (`NOC.v`)**, a testbench (`NoCtestbench.v`), representative modules for GPU, NI, leaf and spine routers, FSMs, FIFOs, ports, and routing tables. Other instances in the full 32-GPU setup are replicated from these representatives.

Below is a **topology diagram** showing the overall architecture of AI GPU Grid:
<img width="921" height="1125" alt="image" src="https://github.com/user-attachments/assets/f0c3961a-2f33-4e14-a03b-224f14c03ffc" />


A single GPU-to-NI-to-leaf-to-spine connection is illustrated here:
<img width="1000" height="641" alt="image" src="https://github.com/user-attachments/assets/b277a4be-95bd-4eda-a3b4-4a6485454610" />


Simulation with `NoCtestbench.v` verifies correct packet transfer, FIFO buffering, and FSM-controlled routing. The design is **scalable, modular, and AXI-compliant**, providing a robust framework for high-performance GPU interconnects.
