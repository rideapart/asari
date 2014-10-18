# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

ArticleList.create([
    { name: 'front page carousel'},
    { name: 'featured articles'}
])
ArticleList.find_by_name('front page carousel').wp_posts = WpPost.only_posts.first(5)
ArticleList.find_by_name('featured articles').wp_posts = WpPost.only_posts.first(8)
