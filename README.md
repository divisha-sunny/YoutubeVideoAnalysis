# YoutubeVideoAnalysis

The data modeling of the project is as follows:

The final clean dataset has the following columns:  
**(video_id, publishedAt, channel_Id, video_title, channel_Title, tags, categoryId, duration, definition, caption, licensedContent, madeForKids, viewCount, likeCount, commentCount, country, category_title, trending_date)**

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
3. `(video_id, publishedAt, video_title, tags, duration, definition, caption, licensedContent, madeForKids)`  
4. `(video_id, trending_date, viewCount, likeCount, commentCount, country)`

---
