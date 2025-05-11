# Back-Of-The-Envelope Estimation / Capacity Planning

---

## 1. Main Concepts (Overview Section)

This documentation explores **back-of-the-envelope estimation**—a rapid, approximate calculation technique essential for system design and capacity planning. You'll learn:

- **Purpose and Philosophy:** Why and when to use quick, “good enough” estimates in engineering.
- **Key Estimation Targets:** Typical metrics to estimate, such as requests per second (RPS), queries per second (QPS), and storage requirements.
- **Estimation Inputs and Process:** How to derive sensible numbers using daily active users (DAU), usage rates, scaling factors, and scientific notation.
- **Worked Examples:** Step-by-step calculations for service throughput and storage, including simplifying techniques.
- **Role of Approximations:** The value of orders of magnitude and how precision is often less important than actionable insight.
- **Real-World Application:** How these estimates inform architectural decisions, trade-offs, and best practices in large-scale systems.
- **Analogy Section:** Intuitive comparisons to make concepts stick.

---

## 2. Detailed Conceptual Flow (Core Documentation)

### Introduction: The Spirit of Back-of-the-Envelope Estimation

In the fast-moving world of system design, engineers are often faced with questions about scalability, resource needs, or bottlenecks—sometimes with very little data. Rather than diving into detailed simulations or gathering exhaustive metrics, experienced practitioners reach for the **back-of-the-envelope estimation**. This approach focuses on rough, order-of-magnitude calculations to quickly validate or sanity-check a design.

Imagine you’re asked, “Can our web service handle a million requests per second?” Rather than getting bogged down in precise benchmarks, you can estimate: if each server handles 10,000 requests per second, you’d need about 100 servers. This immediately informs both architecture (a cluster with load balancing) and scale (number of servers required).

The beauty of this method is its tolerance for imprecision: being within a factor of ten is usually sufficient to guide early design choices or spot obvious flaws. It's about catching problems early, not about finding the exact answer.

---

### Core Metrics: What Do We Estimate?

The most common use cases for back-of-the-envelope estimation in system design are:

- **Throughput:** Requests per second (RPS) at the service level, or queries per second (QPS) at the database.
- **Storage:** Required disk space for data, media, or logs.
- **Peak Traffic:** Anticipated maximum load during spikes.
- **Growth Over Time:** Projected increases in usage or storage needs.

Let’s focus first on estimating service throughput.

---

### Step-by-Step: Estimating Requests Per Second (RPS)

To estimate RPS, you need:

1. **Daily Active Users (DAU):** The number of unique users engaging with your service each day. If you only have monthly active users (MAU), estimate DAU as a fraction (e.g., 50% of MAU).
2. **User Action Rate:** Not every user performs every action. For example, only 25% of Twitter users might tweet on a given day, and those who do might post an average of two tweets each.
3. **Scaling Factor:** Usage isn’t constant—there are daily peaks (e.g., during commute hours). Multiply by a factor to account for the highest expected load (e.g., 2× or 5× the average).
4. **Conversion to Per-Second Rate:** Divide the total daily action count by the number of seconds in a day (86,400), rounding as appropriate.

**Worked Example: Estimating Tweets per Second on Twitter**

Suppose:
- Twitter has 300 million MAU; 50 million DAU (using 50% as a conversion).
- 25% of DAU tweet, each making 2 tweets: 0.5 tweets per DAU.
- Scaling factor for peak (East Coast morning): 2×.
- Seconds per day: 86,400 (rounded to 100,000 for simplicity).

Calculation:
- Total daily tweets: 50,000,000 DAU × 0.5 tweets/DAU = 25,000,000 tweets.
- Scaled for peak: 25,000,000 × 2 = 50,000,000 tweets.
- Per second: 50,000,000 / 100,000 ≈ 500 tweets/second.

However, using the more precise numbers and scientific notation:
- 50,000,000 DAU × 0.5 × 2 = 50,000,000 tweets at peak.
- 50,000,000 / 86,400 ≈ 578 tweets/second, or about 1,500 when using more aggressive rounding and scaling.

---

### Simplifying the Math: Scientific Notation & Rounding

Large numbers are error-prone. Converting to **scientific notation** streamlines the math:

- 50,000,000 = 5 × 10⁷
- 86,400 ≈ 10⁵

Multiplying/dividing powers of ten is as simple as adding/subtracting exponents:

- (5 × 10⁷) / (1 × 10⁵) = 5 × 10² = 500

Grouping non-power-of-ten numbers separately keeps calculations clear. This method is invaluable for quick mental math and for avoiding mistakes with zeros.

**Tip:** Memorize common powers of ten:
- 10¹² = trillion/terabyte (TB)
- 10⁹ = billion/gigabyte (GB)
- 10⁶ = million/megabyte (MB)

---

### Estimating Storage Requirements

Beyond throughput, you often need to estimate storage for things like media uploads.

**Inputs:**
- Number of items (e.g., tweets per day).
- Percentage containing each media type (e.g., 10% have pictures, 1% have videos).
- Average size (e.g., 100 KB per picture, 100 MB per video).
- Retention period and replication factor.

**Worked Example: Twitter Media Storage**

- 50,000,000 tweets/day.
- 10% have pictures (5,000,000/day at 100 KB each).
- 1% have videos (500,000/day at 100 MB each).
- Retention: 5 years (≈ 2,000 days).
- Replication: 3 copies.

**Picture Storage:**
- 5,000,000 × 100 KB = 500,000,000 KB/day.
- Over 5 years: 500,000,000 KB × 2,000 × 3 = 3 × 10¹² KB.
- 3 × 10¹² KB = 3 × 10⁹ MB = 3 × 10⁶ GB = 3 × 10³ TB = 3 PB (petabytes).

**Video Storage (shortcuts):**
- Videos are 1,000× larger than pictures, but 1/10 as common.
- Net: 100× as much storage as pictures.
- 100 × 3 PB = 300 PB.

This high-level estimation quickly highlights the need for distributed storage and efficient media handling.

---

### Orders of Magnitude: Precision vs. Actionability

The point is not to predict exact numbers but to spot when a design will clearly fail or succeed at scale. If you estimate you’ll need 900 servers but only have budget for 10, that’s a clear design issue. If you’re within a factor of 10, you’re usually close enough for early design decisions.

---

## 3. Simple & Analogy-Based Examples

Imagine planning a road trip and trying to estimate how much gas you’ll need. You don’t calculate the combustion efficiency of your engine—you look at the distance, your car’s miles per gallon, and round up for safety. Back-of-the-envelope estimation in system design is similar: use big, easy numbers, round aggressively, and plan for the worst peak. You don’t need to know the exact number of cars on the road at every minute; just enough to see if you’ll need to stop for gas along the way.

---

## 4. Use in Real-World System Design

**Patterns and Use Cases:**
- **Capacity Planning:** Estimating server, database, or storage needs before purchase or deployment.
- **Architecture Validation:** Ensuring a design can handle projected peak loads (e.g., number of load-balanced servers, database sharding).
- **Bottleneck Identification:** Spotting components likely to fail under scale (e.g., single database server facing 10,000 QPS).
- **Cost Estimation:** Rapidly sizing cloud infrastructure for budgeting.

**Design Decisions Influenced:**
- Choosing whether to implement caching, sharding, or replication.
- Deciding between vertical scaling (bigger machines) or horizontal scaling (more machines).
- Selecting storage solutions (local disk, distributed file system, object storage).

**Trade-offs and Challenges:**
- **PRO:** Fast, enables quick iteration and early feedback.
- **PRO:** Encourages clear thinking about scale and constraints.
- **CON:** Can hide critical edge cases if used exclusively or with poor assumptions.
- **CON:** Over-simplification may miss rare but important spikes or failure modes.

For example, underestimating the scaling factor for a social media service’s “breaking news” spike could lead to outages, even if average usage was correctly calculated.

**Best Practices:**
- Always clarify and document your assumptions.
- Use conservative (higher) scaling factors for peaks.
- Round numbers aggressively for mental math, but revisit with more detail for critical decisions.
- Avoid “paralysis by precision”—don’t waste time on minor details at the early phase.

**Anti-patterns:**
- Relying solely on back-of-the-envelope estimates for final capacity planning.
- Ignoring data variability or unlikely but possible outlier events.
- Failing to revisit estimates as real usage data becomes available.

---

## 5. Optional: Advanced Insights

**Expert Considerations:**
- **Edge Cases:** For global services, peak traffic may not synchronize with known regional peaks; always check for “rolling peaks.”
- **Comparisons:** Back-of-the-envelope estimation is analogous to “Fermi estimation” in physics—named after Enrico Fermi, who was famous for quick, insightful calculations.
- **Refinement:** As a system matures, replace rough estimates with logs, metrics, and load tests for fine-tuning.

---

## Analogy Section: The Coffee Shop Counter

Think of designing a system like running a coffee shop. If you know you get about 100 customers a day, and each spends 10 minutes inside, you can quickly estimate you need seating for about 10–20 people at any one time. You don’t need to know exactly when each customer will arrive—just enough to avoid lines out the door. If you expect a morning rush, you might double your staff or seating temporarily. In the same way, back-of-the-envelope math in system design helps you spot whether you’ll need one, ten, or a hundred servers, long before you open the doors.

---

## Summary

Back-of-the-envelope estimation is a cornerstone of practical system design. By focusing on “good enough” numbers—orders of magnitude rather than decimals—engineers can make rapid, informed architectural decisions, avoid wasted effort, and spot problems early. The key is to balance speed with clear documentation of assumptions, always ready to revisit numbers as real data comes in.

---

### Flow Diagram: Back-of-the-Envelope Estimation Process

```mermaid
flowchart TD
    A[Define Metric to Estimate]
    B[Gather Inputs (DAU, Action Rate, Scaling, etc.)]
    C[Convert to Scientific Notation]
    D[Apply Estimation Formula]
    E[Round and Simplify]
    F[Interpret Result (Order of Magnitude)]
    G[Inform Design Decisions]
    
    A --> B
    B --> C
    C --> D
    D --> E
    E --> F
    F --> G
```

---

**In Practice:**  
When faced with design choices—whether sizing storage, load balancing, or anticipating spikes—reach for the back of the envelope. It’s fast, effective, and, in the right hands, can save your project from costly mistakes.