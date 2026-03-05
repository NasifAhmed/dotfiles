## 1. Mean Time Between Failures (MTBF)
The average time a repairable system operates continuously before encountering a failure. 
$$MTBF = \frac{\text{Total Operating Time}}{\text{Number of Failures}}$$
Or,
$$MTBF = \frac{\text{Total Uptime}}{\text{Number of Failures}}$$

## 2. Mean Time To Recovery (MTTR)
The average time it takes to fully restore a failed system to its normal operating state
$$MTTR = \frac{\text{Total Repair Time}}{\text{Number of Failures}}$$
Or,
$$MTTR = \frac{\text{Total Downime}}{\text{Number of Failures}}$$

## 3. Mean Time To Failure (MTTF)
MTBF is used for _repairable_ systems, MTTF is used for _non-repairable_ components. It is the expected lifespan of a single part before it completely dies and must be replaced entirely.
$$MTTF = \frac{\text{Total Hours of Operation}}{\text{Total Number of Defective Units}}$$

## 4. Failure Rate ($\lambda$)
$$\lambda = \frac{1}{MTBF}$$
**Example :** If your server has an MTBF of 250 hours, the failure rate is $1 / 250$, or $0.004$ failures per hour.

## 5. System Availability
$$Availability = \frac{MTBF}{MTBF + MTTR}$$
$$Non-availability = 1 - Availibity = \frac{MTTR}{MTBF + MTTR}$$
**Example :** Using our web server numbers (MTBF = 250 hours, MTTR = 3 hours): 
$$Availability = \frac{250}{250 + 3} = \frac{250}{253} \approx 0.9881$$

$$Non-availability = \frac{3}{250 + 3} = \frac{3}{253} \approx 0.01185$$
Or, $$Non-availability = 1 - Availibility = 1 - 0.9881 = 0.01185$$

This means the server has an availability of **98.81%**.
This means the server has an non-availability of **1.19%**.
Or, This means the server has an non-availability of **100 - 98.81** = **1.19%**.

### a) Availability of Series System
$$A_{sys} = A_1 \times A_2 \times \dots \times A_n$$
**The Example:** Imagine a basic, non-redundant IT pipeline: a Router ($A_1 = 0.99$), a Web Server ($A_2 = 0.95$), and a Database Server ($A_3 = 0.98$).

$$A_{sys} = 0.99 \times 0.95 \times 0.98 = 0.92169$$
The overall system availability is **92.17%**. Notice how the total system is significantly less reliable than the weakest link (the 95% web server).

### b) Availability of Parallel System
Only _one_ of the parallel components needs to function for the system to remain operational. The system only fails if **all** parallel components fail simultaneously.. Instead of calculating the probability that they will all succeed, we calculate the probability that they will all _fail_, and subtract that from 1 (100%).
$$A_{sys} = 1 - ((1 - A_1) \times (1 - A_2) \times \dots \times (1 - A_n))$$
**The Example:** You realize your 95% Web Server from the previous example is a bottleneck. You deploy a second, identical Web Server alongside it in a load-balanced parallel setup. Both have an availability of 0.95 ($A_1 = 0.95, A_2 = 0.95$).
$$A_{sys} = 1 - ((1 - 0.95) \times (1 - 0.95))$$

$$A_{sys} = 1 - (0.05 \times 0.05)$$

$$A_{sys} = 1 - 0.0025 = 0.9975$$
By simply adding a second 95% reliable server in parallel, your web tier availability jumps to **99.75%**.
### c) Availability of Mixed System
Calculate the equivalent availability of any parallel subsystems first. Once you have a single number for the parallel cluster, treat it as a single component in a larger series system.