# portfolio

## Model

```mermaid
erDiagram
  USER{
    bigint id
    string email
    string encrypted_password
    string reset_password_token
    datetime reset_password_sent_at
    datetime remember_created_at
    enum role
    datetime created_at
    datetime updated_at
  }
  PROJECT{
    bigint id
    string title
    string link
    datetime created_at
    datetime updated_at
  }
  ARTICLE ||--o{ PUBLISHMENT : has_publishments
  ARTICLE{
    bigint id
    string title
    text content
    enum status
    datetime created_at
    datetime updated_at
  }
  PUBLISHMENT{
    bigint id
    bigint article_id
    datetime published_at
    datetime created_at
    datetime updated_at
  }
  IMAGE }o--|| CAMERA : uses
  IMAGE }o--|| LENS : uses
  IMAGE{
    bigint id
    string title
    string caption
    datetime taken_at
    bigint camera_id
    bigint lens_id
    int display_order
    bool is_published
    datetime created_at
    datetime updated_at
  }
  LENS{
    bigint id
    string name
    datetime created_at
    datetime updated_at
  }
  CAMERA{
    bigint id
    string name
    string manufacturer
    datetime created_at
    datetime updated_at
  }
  IMAGE ||--o{ IMAGE_CATEGORY: has_many
  CATEGORY ||--o{ IMAGE_CATEGORY: has_many
  CATEGORY{
    bigint id
    string name
    datetime created_at
    datetime updated_at
  }
  IMAGE_CATEGORY{
    bigint id
    bigint image_id
    bigint category_id
    datetime created_at
    datetime updated_at
  }
```
