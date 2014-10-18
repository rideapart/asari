class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :name
      t.timestamps
    end

    create_table :article_lists do |t|
      t.string :name
      t.timestamps
    end

    create_table :article_lists_wp_posts, id: false do |t|
      t.belongs_to :wp_post
      t.belongs_to :article_list
    end
  end
end