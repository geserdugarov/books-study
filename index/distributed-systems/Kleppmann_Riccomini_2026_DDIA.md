# Designing Data-Intensive Applications (Second Edition)

## Book Metadata
- **Title:** Designing Data-Intensive Applications: The Big Ideas Behind Reliable, Scalable, and Maintainable Systems
- **Authors:** Martin Kleppmann, Chris Riccomini
- **Publisher:** O'Reilly Media
- **Year:** 2026 (Second Edition)
- **Pages:** 673

## Target Audience and Prerequisites
- Backend engineers and systems architects designing data infrastructure
- Data engineers building pipelines and integrating systems
- Full-stack developers working on scalable applications
- Requires software engineering fundamentals (programming, basic database knowledge)
- Distributed systems knowledge built from ground up in the book

## Overall Focus
Deep understanding of principles underlying modern data systems -- not just how individual technologies work, but why they work that way and what trade-offs they make. Examines real systems (Kafka, Redis, Cassandra, PostgreSQL, etc.) and extracts key design decisions. The second edition (2026) adds cloud-native architectures, AI/ML pipeline requirements, privacy regulations, and ethical implications. Core thesis: different technologies make different trade-offs; understanding these enables intelligent architectural choices.

---

## Table of Contents

### Chapter 1: Trade-Offs in Data Systems Architecture (pp. 1-31)
- Operational vs Analytical Systems (OLTP vs OLAP)
- Data Warehousing, Data Lakes, Beyond Data Lakes
- Systems of Record and Derived Data
- Cloud vs Self-Hosting (pros/cons, cloud native, operations)
- Distributed vs Single-Node Systems (problems, microservices, serverless)
- Data Systems, Law, and Society

**Summary:** Foundational framework: OLTP vs OLAP, data warehouses/lakes, cloud vs self-hosted, single-node vs distributed tradeoffs. Introduces microservices, serverless, and the intersection of data systems with law and society (privacy, compliance).

### Chapter 2: Defining Nonfunctional Requirements (pp. 33-63)
- Case Study: Social Network Home Timelines
- Describing Performance (latency, percentiles, SLOs)
- Reliability and Fault Tolerance (hardware/software/human faults)
- Scalability (load, shared-nothing architecture)
- Maintainability (operability, simplicity, evolvability)

**Summary:** How to measure and reason about system properties. Performance (latency percentiles), reliability (fault tolerance), scalability (load characterization, shared-nothing), and maintainability. These requirements drive architectural choices.

### Chapter 3: Data Models and Query Languages (pp. 65-112)
- Relational vs Document Models (object-relational mismatch, normalization)
- Stars and Snowflakes for Analytics
- Graph-Like Data Models (Property Graphs, Cypher, SPARQL, Datalog, GraphQL)
- Event Sourcing and CQRS
- DataFrames, Matrices, and Arrays

**Summary:** Comparing data models: relational, document, graph. When each is appropriate, query languages (SQL, Cypher, SPARQL, Datalog, GraphQL), event sourcing/CQRS patterns, and DataFrames for ML.

### Chapter 4: Storage and Retrieval (pp. 115-159)
- OLTP Indexing: Log-Structured (LSM-Trees) vs B-Trees
- Multicolumn and Secondary Indexes, In-Memory Storage
- Analytics: Column-Oriented Storage, Vectorization, Materialized Views
- Full-Text Search, Vector Embeddings

**Summary:** How databases store and retrieve data. Compares LSM-Trees vs B-Trees, covers column-oriented storage for analytics, vectorized query execution, and modern additions: full-text search and vector embeddings for similarity search.

### Chapter 5: Encoding and Evolution (pp. 161-195)
- Encoding Formats (JSON, XML, Protocol Buffers, Avro)
- Schema Evolution (backward/forward compatibility)
- Dataflow: Through Databases, Services (REST/RPC), Durable Execution, Event-Driven

**Summary:** Data serialization and transmission. Compares encoding formats, explains why schemas matter for evolution. Covers dataflow modes: databases, REST/RPC services, durable execution workflows, and event-driven architectures.

### Chapter 6: Replication (pp. 197-250)
- Single-Leader (sync vs async, node outages, replication lag)
- Multi-Leader (geo-distributed, local-first, conflict resolution)
- Leaderless (quorums, concurrent write detection)

**Summary:** Keeping multiple data copies consistent. Single-leader (most common), multi-leader (geo-distributed), and leaderless (Dynamo-style) replication. Core tradeoff: stronger consistency requires more coordination, increasing latency.

### Chapter 7: Sharding (pp. 251-275)
- Pros/Cons of Sharding, Multitenancy
- Key Range vs Hash-Based Sharding, Hot Spots
- Automatic vs Manual Rebalancing
- Request Routing
- Secondary Indexes (local vs global)

**Summary:** Scaling writes by distributing data across nodes. Key range vs hash sharding, hot spot handling, rebalancing, request routing, and the complexity secondary indexes add to sharded systems.

### Chapter 8: Transactions (pp. 277-344)
- ACID Properties
- Weak Isolation (Read Committed, Snapshot Isolation, Lost Updates, Write Skew)
- Serializability (Serial Execution, Two-Phase Locking, SSI)
- Distributed Transactions (Two-Phase Commit, exactly-once processing)

**Summary:** Transactions for data correctness. ACID properties, weak isolation levels (commonly used for performance) and their problems, strong isolation (serializability) through various mechanisms, and distributed transactions with 2PC.

### Chapter 9: The Trouble with Distributed Systems (pp. 345-399)
- Unreliable Networks (TCP limitations, fault detection, timeouts)
- Unreliable Clocks (monotonic vs time-of-day, drift, process pauses)
- Knowledge, Truth, and Lies (majority rules, distributed locks, Byzantine faults)
- System Models, Formal Methods, Randomized Testing

**Summary:** Why distributed systems are hard. Unreliable networks with unbounded delays, clock skew and process pauses, and the impossibility of reliable failure detection. Introduces system models (synchronous, partially synchronous, asynchronous).

### Chapter 10: Consistency and Consensus (pp. 401-449)
- Linearizability (what, why, implementing, cost)
- ID Generators and Logical Clocks
- Consensus (many faces, practical algorithms, Raft, coordination services)

**Summary:** Solutions to distributed problems. Linearizability as a consistency model, logical clocks as alternatives to physical clocks, and consensus algorithms (Raft). Coordination services (Zookeeper, etcd) and why consensus is expensive.

### Chapter 11: Batch Processing (pp. 451-485)
- Unix Tools as Batch Processing Model
- Distributed: Filesystems (HDFS), Object Stores, Job Orchestration
- Models: MapReduce, Dataflow Engines, Shuffling, Joins
- Use Cases: ETL, Analytics, Machine Learning, Serving Derived Data

**Summary:** Processing large data volumes through batch jobs. From Unix tools to MapReduce and modern dataflow engines (Spark). Covers distributed filesystems, joins/grouping, SQL engines, DataFrames, and use cases (ETL, ML pipelines).

### Chapter 12: Stream Processing (pp. 487-537)
- Messaging Systems (Kafka, RabbitMQ), Log-Based Brokers
- Databases and Streams, Change Data Capture
- Processing: Time semantics (event vs processing time), Windowing
- Stream Joins, Fault Tolerance (exactly-once semantics)

**Summary:** Continuous event flow processing. Message brokers, change data capture (CDC), event time vs processing time, windowing semantics, stream joins, and exactly-once semantics for fault tolerance.

### Chapter 13: A Philosophy of Streaming Systems (pp. 539-581)
- Data Integration (combining specialized tools, batch + stream)
- Unbundling Databases (composing storage technologies)
- Designing Around Dataflow (observing derived state)
- Aiming for Correctness (end-to-end argument, constraints, timeliness/integrity)

**Summary:** Integrated philosophy for building systems with streams. Unbundling databases into specialized components connected via streams. Dataflow-oriented design, end-to-end correctness argument, idempotent operations, and immutability for auditability.

### Chapter 14: Doing the Right Thing (pp. 585-601)
- Predictive Analytics (bias, discrimination, feedback loops)
- Privacy and Tracking (surveillance, consent)
- Data as Assets and Power (legislation, self-regulation)

**Summary:** Ethics and societal implications. Bias in ML models, feedback loops amplifying discrimination, privacy/surveillance concerns, data governance, and regulations (GDPR, CCPA). Data systems are not just a technical problem but a human and social one.

### Glossary (pp. 603-607)
### Index (pp. 609-673)

---

## Key Topics and Concepts

### Fundamental Trade-offs
- Consistency vs Availability vs Partition Tolerance
- Strong consistency vs high availability
- Normalization vs denormalization
- Synchronous vs asynchronous replication
- Batch vs stream processing (latency vs simplicity)
- Strong isolation vs performance

### Storage and Indexing
- B-Trees vs LSM-Trees
- Column-oriented storage and compression
- Full-text search, Vector embeddings
- Data warehouses vs data lakes

### Distributed Systems
- Replication (single-leader, multi-leader, leaderless)
- Sharding (key range, hash-based, hot spots)
- Consensus algorithms (Raft, Zookeeper, etcd)
- Linearizability and logical clocks
- Network unreliability, clock skew, process pauses
- Byzantine faults

### Transactions
- ACID properties and isolation levels
- Snapshot isolation, serializable snapshot isolation
- Two-phase locking, two-phase commit
- Distributed transactions

### Data Processing
- MapReduce and dataflow engines (Spark)
- Stream processing (Kafka, CDC)
- Event time vs processing time, windowing
- Exactly-once semantics
- ETL, analytics, ML pipelines

### Architecture Patterns
- OLTP vs OLAP
- Event sourcing and CQRS
- Microservices and serverless
- Cloud-native system architecture
- Data integration via change data capture

### Ethics and Governance
- Bias and discrimination in ML
- Privacy, surveillance, consent
- GDPR, CCPA compliance
- Data as power
