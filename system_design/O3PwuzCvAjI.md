# How Discord Stores TRILLIONS of Messages: The Great Database Migration

---

## 1. Main Concepts (Overview Section)

This documentation walks through Discord’s monumental migration of trillions of chat messages from their legacy Cassandra database to a new, high-performance system called ZillaDB. The journey highlights not only technical ingenuity but also sophisticated risk management and engineering culture. The key concepts and subtopics covered are:

- **Background & Motivation**: Why Discord needed to move away from Cassandra.
- **Cassandra’s Pain Points**: Scalability, performance, and operational headaches.
- **Choosing ZillaDB**: A new, compatible but fundamentally different database.
- **Migration Strategy**: Incremental, reversible steps and risk mitigation.
- **Intermediate Data Services Layer**: Rust-based request coalescing for efficiency.
- **The Super Disk Architecture**: Hybrid storage using local SSDs and Google Cloud persistent disks for low-latency reads and durable writes.
- **Execution of the Migration**: Tools, tactics, and the astonishingly rapid, no-downtime transfer.
- **Results and Lessons Learned**: Improved reliability, performance, and on-call life.

By following this narrative, you’ll learn not just how Discord moved an unimaginable volume of data, but also how to approach large-scale system migrations with a balance of caution and bold innovation.

---

## 2. Detailed Conceptual Flow (Core Documentation)

### The Challenge: Cassandra’s Growing Pains

As Discord’s popularity exploded, so did the demands on its backend infrastructure. The original message storage was built on **Cassandra**, a distributed NoSQL database chosen for its ability to scale horizontally and handle vast amounts of data. For a time, this architecture served Discord well, storing trillions of messages across 77 nodes by 2022.

However, with scale came trouble. Cassandra’s performance became increasingly unpredictable. Latency spikes—unexpected slowdowns in reading or writing data—became commonplace, especially as the system grew. The operational burden was immense: keeping the database cluster healthy required constant vigilance and frequent on-call interventions. The team found themselves fighting fires rather than building features.

Cassandra, like many Java-based systems, also suffered from **garbage collection (GC)** issues. GC is the process by which old, unused memory is cleaned up, but if not managed well, it can pause the entire process—a nightmare in a system that’s supposed to be always-on and highly responsive.

### The Need for Change: Enter ZillaDB

The Discord engineering team knew they needed a new solution. Enter **ZillaDB**: a new, Cassandra-compatible database engine, but written in C++ for maximum performance. This meant Discord could keep their existing data model and APIs, while swapping out the problematic engine underneath.

ZillaDB’s most attractive feature was its lack of garbage collection—a significant improvement over Cassandra’s Java-based approach. It also promised faster repairs (critical in distributed databases) and more predictable performance.

But a migration of this scale—trillions of messages, mission-critical data, and a massive user base—was a high-stakes affair. Discord’s engineering culture emphasizes moving fast when mistakes are reversible, but slowing down and meticulously planning when the risk is existential. They wisely chose to rehearse by migrating smaller, less critical databases first, ironing out issues and building confidence before addressing the main message cluster.

### The Data Services Layer: Smarter Access, Less Load

To prepare for the migration and improve overall system resilience, Discord introduced a new **intermediate layer** between their API monolith (the main backend service) and the database clusters. This layer, called **data services**, was written in Rust—a language known for its safety and performance.

A standout feature of this layer is **request coalescing**. In large distributed systems, it’s common for many users to request the same data at the same time. Instead of bombarding the database with duplicate queries, the data services layer aggregates these requests, issuing a single query to the database and sharing the result among all waiting clients. This dramatically reduces unnecessary load, prevents bottlenecks, and helps avoid issues like “hard partitions” (where the database is overwhelmed and splits into isolated segments).

Imagine a popular Discord server where thousands of people might ask for the same chat history at once. With request coalescing, the database serves just one request, not thousands—leading to smoother, faster user experiences.

### The Super Disk: Reinventing Storage for Scale

As Discord scaled, they faced another crucial challenge: **disk latency**. Their cloud architecture (on Google Cloud) offered two primary options for storage:

- **Local NVMe SSDs**: Extremely fast, but less durable and not persistent across machine failures.
- **Google Cloud Persistent Disks**: Highly reliable and durable, but slower due to being network-attached.

Neither option alone met Discord’s needs for both low-latency reads (for speed) and durable, reliable writes (for safety).

The engineering team devised a novel solution dubbed the **super disk**. This is a hybrid storage system created entirely in software, combining the best features of both disk types using Linux’s RAID (Redundant Array of Independent Disks) capabilities:

- **RAID 0 (Striping)**: Combines multiple local SSDs into a single, high-speed virtual disk—maximizing read speed.
- **RAID 1 (Mirroring)**: Mirrors this virtual SSD array with a persistent disk—ensuring that all writes are safely duplicated to durable storage.

Linux was configured to direct all **writes** to the persistent disk (for durability), while **reads** came from the fast local SSDs (for low latency). This custom setup delivered the low-latency performance users expected, without compromising on data safety or availability.

### Execution: Migrating Trillions of Messages

With the new infrastructure in place—ZillaDB clusters, data services layer, and super disk storage—Discord was finally ready to tackle the main event: migrating trillions of messages.

The migration was orchestrated with a custom **disk migrator tool**, also built in Rust for reliability and speed. Thanks to careful planning and risk mitigation, the team completed the migration in just **nine days**, with **zero downtime** for end users. At its core, this was a live, hot-swap replacement of the database engine serving Discord’s most critical workload.

The end result? Discord was able to reduce its cluster from 77 Cassandra nodes to just 72 ZillaDB nodes—a leaner, faster, and more stable setup.

---

## 3. Simple & Analogy-Based Examples

Suppose you run a busy library (the database) with hundreds of librarians (nodes) helping visitors (users) find books (messages). The library’s old system (Cassandra) is slow—sometimes a librarian has to stop working to clean up their workspace (garbage collection), and the catalog system occasionally breaks, causing delays and confusion.

To fix this, you install a new, more efficient catalog (ZillaDB) that doesn’t require these periodic slowdowns. You also put in place a clever receptionist (the data services layer) who, if multiple visitors ask for the same book, fetches it just once and gives copies to everyone—avoiding a rush on the shelves.

Finally, you recognize that your storage room has two areas: a lightning-fast but fragile closet (local SSD) and a secure, slightly slower vault (persistent disk). You build a system where new books are always copied to the vault for safekeeping, but most library visitors grab books from the fast closet, so service is speedy and nothing valuable is ever lost.

---

## 4. Use in Real-World System Design

### Practical Patterns and Use Cases

- **Layered Architecture**: Introducing an intermediate data services layer is a common pattern for insulating application logic from backend changes, enabling easier migrations, feature rollouts, and performance optimizations.
- **Request Coalescing**: Particularly valuable in high-read, high-concurrency systems such as chat apps, social media feeds, or real-time dashboards.
- **Hybrid Storage Solutions**: The super disk pattern can be adapted wherever cloud storage offers trade-offs between performance and durability.

### Design Decisions and Trade-offs

- **Database Compatibility vs. Rebuild**: By choosing ZillaDB’s Cassandra compatibility, Discord avoided a costly rewrite of their data model and APIs, reducing migration risk.
- **Safety-First Migrations**: Testing on smaller datasets first let them catch bugs and edge cases with minimal user impact—a best practice for any high-stakes change.
- **Custom Storage Layer**: Building a bespoke super disk required deep OS and cloud expertise but paid off in performance and reliability.

#### Trade-offs

- **Complexity vs. Control**: Custom solutions like the super disk offer fine-grained control but increase operational complexity and require specialist skills.
- **Performance vs. Cost**: More performant storage and additional architectural layers often mean higher cloud costs and engineering investment.

### Best Practices

- **Plan for Reversibility**: Make migration steps small and reversible wherever possible.
- **Monitor and Mitigate Risks Early**: Use smaller, lower-impact migrations as testbeds.
- **Automate and Instrument**: Build reliable migration tools with robust monitoring for early detection of problems.

### Anti-Patterns to Avoid

- **“Big Bang” Migrations**: Attempting to migrate everything in one go, without incremental steps or rollback options, can lead to catastrophic failures.
- **Ignoring Operational Pain**: Failing to address accumulating technical debt (like Cassandra’s GC issues) can slow development and burn out teams.

---

## 5. Optional: Advanced Insights

### Deeper Technical Considerations

- **Java vs. C++ in Database Engines**: Java’s managed memory and GC can cause unpredictable pauses, especially under heavy load. C++ offers more predictable resource management at the cost of potential memory safety pitfalls—Rust can combine the best of both worlds, as seen in the data services layer.
- **Request Coalescing at Scale**: This can introduce subtle consistency or caching bugs if not carefully implemented, especially with rapidly changing data.
- **Cloud Storage Innovation**: The super disk is a powerful example of using commodity cloud infrastructure in novel ways to achieve performance that would otherwise require expensive dedicated hardware.

### Edge Cases

- **Failover Handling**: Mirroring writes to persistent disks doesn’t guarantee zero data loss if local SSDs fail before the write is acknowledged—careful tuning of write acknowledgments and replication needed.
- **Hot Data and Cold Data**: Not all messages are accessed equally; popular Discord channels (“hot data”) benefit more from low-latency storage than rarely accessed archives (“cold data”).

---

## 6. All-in-One Analogy Section

**The Discord Database Migration as a City’s Postal Service Overhaul:**

- **Old System (Cassandra)**: Like a city with hundreds of post offices, each with its own filing quirks and staff who sometimes need to stop work to tidy up (garbage collection). Deliveries are sometimes late or lost, and the central postmaster is always getting called to fix problems.
- **New Engine (ZillaDB)**: A high-tech, super-efficient postal system that fits seamlessly into the city, but never needs to stop for cleanup, and delivers faster and more predictably.
- **Data Services Layer (Receptionist)**: A central dispatcher who notices when lots of people want the same package and ensures only one courier picks it up, distributing it efficiently—no more traffic jams at the post office.
- **Super Disk (Storage Hybrid)**: Important letters are always copied to a fireproof vault for safety, but most are handed out from a quick-access shelf so citizens don’t have to wait.
- **Migration Process**: The city introduces these changes gradually—starting with smaller neighborhoods before upgrading the downtown core—ensuring no mail is lost and the city never sleeps.

---

## 7. Flow Diagram

Below is a high-level flow diagram representing the architecture and migration process:

```plaintext
+------------------------+
|    API Monolith        |
+------------------------+
           |
           v
+------------------------+
|   Data Services Layer  |   <-- Request Coalescing (Rust)
+------------------------+
           |
           v
+------------------------+
|     ZillaDB Cluster    |   <-- C++ Engine (Cassandra-Compatible)
+------------------------+
           |
           v
+-----------------+    +-------------------+
| Local SSDs      |    | Persistent Disks  |
|  (Low Latency)  |    |   (Durable)       |
+--------+--------+    +--------+----------+
         |                      |
         +----------+-----------+
                    |
              Super Disk Layer
       (RAID 0 for SSDs + RAID 1 Mirror)
                    |
            Linux Kernel Routing
    (Reads -> SSDs | Writes -> Persistent)
```

---

## 8. Conclusion

Discord’s migration of trillions of messages is a masterclass in high-stakes, high-scale system engineering. By deeply understanding their pain points, leveraging compatible but superior technology, and inventing new solutions (like the super disk), Discord’s team achieved an almost seamless transition with massive operational gains. The lessons here—about risk, reversibility, and innovating from first principles—are broadly applicable to any large, evolving software system.

---