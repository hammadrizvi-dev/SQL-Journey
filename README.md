<div align="center">

# 🗄️ SQL Journey (MySQL & SQLite)

**Structured SQL practice, interview problem-solving, and business analytics queries — verified automatically with GitHub Actions.**

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white)
![SQL CI](https://github.com/hammadrizvi-dev/SQL-Journey/actions/workflows/sql-ci.yml/badge.svg)

</div>

---

## 📂 Structure

```text
SQL-Journey/
├── .github/workflows/sql-ci.yml   # Automated SQL verification on every push
├── 01-basics-and-joins/
│   ├── sqlite/                    # Runnable anywhere with sqlite3 (01_schema, 02_questions, 03_solutions)
│   ├── mysql/                     # MySQL 8+ compatible schema & solutions
│   └── NOTES.md                   # Quick revision notes
├── 02-ctes-and-subqueries/
│   ├── sqlite/                    # 10 CTE & Subquery problems on HR/Projects schema
│   ├── business-analytics/        # 10 Revenue, Cohort & Retention analytics queries + schema
│   └── NOTES.md                   # Quick revision notes
├── 03-window-functions/
│   ├── sqlite/                    # 10 Ranking, NTILE & Partition window function problems
│   └── NOTES.md                   # Quick revision notes (ROW_NUMBER vs RANK vs DENSE_RANK)
└── README.md
```

## 📈 Roadmap

| Module | Topics | Status |
|---|---|---|
| **01** | Basics, Aggregates, `GROUP BY`, `HAVING`, `JOIN`s, Self-Join, `CASE`, Subqueries (18 queries) | ✅ Done |
| **02** | CTEs (`WITH`), Subqueries & Business Analytics — Revenue, Cohort, Retention (20 queries) | ✅ Done |
| **03 (Part 1)** | Window Functions — `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `NTILE`, `PARTITION BY` (10 queries) | ✅ Done |
| **03 (Part 2)** | Window Functions — `LAG`, `LEAD`, Running Totals, Moving Averages | 🔄 Next |
| **04** | LeetCode / Interview Top 50 SQL Problems | ⏳ Upcoming |
| **05** | End-to-End Business Analytics Case Study (Sales / E-commerce) | ⏳ Upcoming |

## ⚙️ Run Locally (Zero Setup with SQLite)

```bash
git clone https://github.com/hammadrizvi-dev/SQL-Journey.git
cd SQL-Journey
sqlite3 practice.db < 01-basics-and-joins/sqlite/01_schema_and_seed.sql
sqlite3 -header -column practice.db < 01-basics-and-joins/sqlite/03_solutions.sql
```

For **MySQL 8+**:
```bash
mysql -u root -p < 01-basics-and-joins/mysql/01_schema_and_seed.sql
mysql -u root -p < 01-basics-and-joins/mysql/02_solutions.sql
```

---

<div align="center"><sub>Maintained by <a href="https://github.com/hammadrizvi-dev">Hammad Rizvi</a> • <a href="https://www.linkedin.com/in/hammadrizvi-dev">LinkedIn</a></sub></div>
