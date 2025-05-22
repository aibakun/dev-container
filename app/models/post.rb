class Post < ApplicationRecord
  include Paginatable
  belongs_to :user
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags

  validates :title, presence: true, length: { maximum: 20 }
  validates :content, presence: true, length: { maximum: 200 }

  scope :recent, -> { order(created_at: :desc) }
  scope :draft, -> { where(published_at: nil) }
  scope :published, -> { where('published_at <= ? AND archived = ?', Time.current, false) }
  scope :scheduled, -> { where('published_at > ?', Time.current) }
  scope :archived, -> { where(archived: true) }

  def update_tags(new_tag_ids)
    return if new_tag_ids.nil?

    new_tag_ids = new_tag_ids.reject(&:blank?).map(&:to_i).uniq
    existing_tag_ids = tags.pluck(:id)

    tags_to_add = new_tag_ids - existing_tag_ids
    tags_to_remove = existing_tag_ids - new_tag_ids

    return if tags_to_add.empty? && tags_to_remove.empty?

    tags << Tag.where(id: tags_to_add) if tags_to_add.any?
    tags.delete(Tag.where(id: tags_to_remove)) if tags_to_remove.any?
  end

  def publish_post(time = Time.current)
    return false if time > Time.current

    update(published_at: time, archived: false)
  end

  def unpublish_post
    update(published_at: nil, archived: false)
  end

  def schedule_post(time)
    return false if time <= Time.current

    update(published_at: time, archived: false)
  end

  def archive_post
    return false unless published?

    update(archived: true)
  end

  def unarchive_post
    return false unless archived?

    update(archived: false)
  end

  def draft?
    published_at.nil? && !archived?
  end

  def published?
    published_at.present? && published_at <= Time.current && !archived?
  end

  def scheduled?
    published_at.present? && published_at > Time.current && !archived?
  end

  def archived?
    archived
  end
end
