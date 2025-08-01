# YoutubeVideoAnalysis

The data modeling of the project is as follows:

The final clean dataset has the following columns:  
**(video_id, publishedAt, channel_Id, video_title, channel_Title, tags, categoryId, duration, definition, caption, licensedContent, madeForKids, viewCount, likeCount, commentCount, country, category_title, trending_date)**

For this project, I’m going with a STAR schema because it’s simpler and way faster for analysis. Since I’ll be loading data regularly and mainly using it for dashboards and quick queries, STAR makes the most sense. It’s easy to work with, scales well, and fits the way I want to slice the data by things like country, category, or channel.

**Here’s the STAR schema I’m using:**

dim_channel - (channel_id, channel_title)
dim_category - (category_id, category_title)
dim_country - (country_id, country)
dim_video - (video_id, video_title, tags, duration, definition, caption, licensedContent, publishedAt)
fact_video_trending_metrics - (video_id, channel_id, category_id, trending_date, viewCount, likeCount, commentCount, country_id)

<img width="3304" height="1360" alt="image" src="https://github.com/user-attachments/assets/5d2354d4-6967-438e-97db-d4aec02b8fce" />


That said, if I wanted to normalize the data fully, I already thought through how that would look — went through 1NF, 2NF, 3NF, and BCNF just to get a clear picture. So I’m keeping those notes here too, just in case I want to revisit it or share with someone who cares about normalization.

---

### 1NF:

In our case:
- Each row has **atomic values**.
- Each row represents a **single entity**.
- Talking about the **"tags"** column, I am treating it as **one whole entity**, not splitting it by commas. This is because it's only used for **text analysis** and a **visualization (e.g., word cloud)** on the dashboard.  
→ Hence, the table satisfies **1NF**.

---

### 2NF:

To satisfy 2NF, we need to **remove partial dependencies**, meaning that **no non-key column should depend on part of a composite key**.

In our case:
- The composite key is **(video_id, trending_date)**.
- The following attributes depend **only on `video_id`** and **not on `trending_date`**, so they are moved into separate tables:

  - `channel_id`, `channel_title` → depend only on `video_id`.
  - `category_id`, `category_title` → depend only on `video_id`.
  - `publishedAt`, `video_title`, `tags`, `duration`, `definition`, `caption`, `licensedContent`, `madeForKids` → all depend on `video_id`.

- The remaining table with `video_id` and `trending_date` contains attributes that are specific to the **video’s status on a particular trending date**:
  - `viewCount`, `likeCount`, `commentCount`, and `country`.

👉 **Note on `country`**:  
Although `country` might seem like a static property, in this dataset it represents the **region where the video was trending** on that specific date. Therefore, it depends on the **composite key (video_id, trending_date)** and rightfully stays in this table.

---

### So after 2NF, we have the following tables:

1. `(channel_id, channel_title)`  
2. `(category_id, category_title)`  
3. `(video_id, publishedAt, video_title, tags, duration, definition, caption, licensedContent, madeForKids, channel_id, category_id)`  
4. `(video_id, trending_date, viewCount, likeCount, commentCount, country)`

dim_channel - (channel_id, channel_title)
dim_category - (category_id, category_title)
dim_country - (country_id, country)
fact_video - (video_id, channel_id, category_id, trending_date, viewCount, likeCount, commentCount, country_id)
dim_video - (video_id, video_title, tags, duration, definition, caption, licensedContent, publishedAt)

---

### 3NF:

To satisfy 3NF, there should be **no transitive dependencies** — i.e., **non-key attributes** should not depend on **other non-key attributes**.

In our case:
- All non-key attributes directly depend on their respective **primary keys**.
- `channel_title` depends only on `channel_id`  
- `category_title` depends only on `category_id`  
- Other columns like `video_title`, `tags`, `publishedAt`, etc. depend directly on `video_id`.
- Columns like  `trending_date`, `viewCount`, etc. depend on `(video_id, trending_date)`.
→ No transitive dependencies exist.

✅ Hence, the schema satisfies **3NF**.

---

### BCNF:

BCNF is a stronger version of 3NF, which requires that **every determinant is a candidate key**.

In our case:
- All functional dependencies have **candidate keys** as determinants:
  - `channel_id → channel_title`
  - `category_id → category_title`
  - `video_id → publishedAt, video_title, ...`
  - `(video_id, trending_date) → viewCount, likeCount, ...`

✅ All dependencies meet the condition → Schema is in **BCNF**.

---
