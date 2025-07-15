
## Database Project

This repository contains the implementation of a university course project for designing and implementing a database system. The system includes schema creation, data population, optimization features, and advanced queries to support analytics and recommendations.

### 📂 Repository Structure

```markdown
/ sql
├── Crea\_schema.sql               # DDL statements to create tables, relationships, constraints
├── Popolamento.sql               # DML statements to populate tables with sample data
├── trigger.sql                   # Definitions of database triggers
├── creazione\_visualizzazione\_attuali.sql # View definitions for current-state data
├── Operazione 1\_8.sql            # Complex operations 1.8 (e.g., transactions, joins)
├── classifiche.sql               # Queries for computing rankings or leaderboards
├── Raccomandazione (2.4.4).sql   # Recommendation engine queries (section 2.4.4)
├── analytics\_abbonamenti.sql     # Analytical queries on subscriptions
├── Bilanciamento\_del\_carico.sql  # Load balancing setup (e.g., partitioning/sharding)
├── Caching.sql                   # Caching strategies (e.g., materialized views or indexed views)
├── Cambio server.sql             # Scripts to migrate or switch database servers
```
```markdown
/ docs
├── Progetto A.A. 22-23.pdf       # Project specification (assignment brief)
├── Documentazione.pdf            # Detailed project documentation and user manual
├── Schema ER.pdf                 # Original Entity-Relationship diagram
├── Schema ristrutturato.pdf      # Restructured (normalized) ER diagram
```


---

## 📝 Project Overview
The goal of this project is to design, implement, and document a robust relational database that supports:

- **Schema design** with properly normalized tables and enforced referential integrity.
- **Data population** with realistic sample data.
- **Views and materialized views** to simplify access to common queries and support caching.
- **Triggers** to enforce business rules and automate updates.
- **Advanced operations** including complex joins, transactions, and multi-step procedures.
- **Performance optimizations** such as load balancing, caching, and server migration support.
- **Analytics and reporting** on subscriptions, user rankings, and usage statistics.
- **Recommendation engine** queries to suggest items based on historical data.

Refer to the included documentation for full requirements and design rationale.

---

## 🚀 Getting Started

### Prerequisites
- A relational database system (e.g., MySQL, PostgreSQL, or SQL Server).
- SQL client or command-line access.
- PDF reader to view the design documents in `/docs`.

### Installation & Execution
1. **Create the schema**
   ```sql
   -- Connect to your database and run:
   sql/Crea_schema.sql


2. **Populate sample data**

   ```sql
   sql/Popolamento.sql
   ```

3. **Create views**

   ```sql
   sql/creazione_visualizzazione_attuali.sql
   ```

4. **Set up triggers**

   ```sql
   sql/trigger.sql
   ```

5. **Run optimization scripts**

   * Load balancing: `sql/Bilanciamento_del_carico.sql`
   * Caching: `sql/Caching.sql`
   * Server migration: `sql/Cambio server.sql`

6. **Execute analytical and recommendation queries**

   ```sql
   sql/analytics_abbonamenti.sql
   sql/classifiche.sql
   sql/Raccomandazione (2.4.4).sql
   ```

---

## 📚 Documentation

* **Project specification**: See `docs/Progetto A.A. 22-23.pdf`
* **User manual & design doc**: See `docs/Documentazione.pdf`
* **ER Diagrams**:

  * Original: `docs/Schema ER.pdf`
  * Restructured: `docs/Schema ristrutturato.pdf`

---

## 👥 Authors

* **Antonio Querci**
* **Team Member 2**


---

## 📄 License

This project is licensed under the MIT License.

