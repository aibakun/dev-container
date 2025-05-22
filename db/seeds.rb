100.times do |i|
  user = User.create!(
    name: "Test User #{i + 1}",
    email: "shoki.surface+test#{i + 1}@gmail.com",
    password: "password#{i + 1}",
    occupation: User.occupations.keys.sample
  )
  user.create_profile!(biography: "Biography for Test User #{i + 1}")
  user.posts.create!(
    title: "Test User #{i + 1}",
    content: "Body for Test User #{i + 1}",
    published_at: [nil, Time.current, Time.current + 1.day].sample
  )
end

keito = User.create!(
  name: 'Keito Tabuchi',
  email: 'k_tabuchi@ga-tech.co.jp',
  password: 'k_tabuchi@ga-tech.co.jp',
  occupation: :employee
)
keito.create_profile!(biography: 'Biography for Keito Tabuchi')
keito.posts.create!(
  title: 'Keito Tabuchi',
  content: 'Body for Keito Tabuchi',
  published_at: Time.current
)

masashi = User.create!(
  name: 'Masashi Watahiki',
  email: 'm_watahiki2@ga-tech.co.jp',
  password: 'm_watahiki2@ga-tech.co.jp',
  occupation: :employee
)
masashi.create_profile!(biography: 'Biography for Masashi Watahiki')
masashi.posts.create!(
  title: 'Masashi Watahiki',
  content: 'Body for Masashi Watahiki',
  published_at: Time.current
)

5000.times do |i|
  random_user = User.all.sample
  random_user.posts.create!(
    title: "Additional Post #{i + 1}",
    content: "This is additional post content #{i + 1}. Created by #{random_user.name}",
    published_at: [nil, Time.current, Time.current + 1.day, Time.current - rand(1..30).days].sample
  )
end

tags = ['Ruby', 'Rails', 'JavaScript', 'HTML', 'CSS', 'Python', 'Java', 'C#', 'PHP', 'Swift']
tags.each do |tag_name|
  Tag.find_or_create_by!(name: tag_name)
end

Post.all.each do |post|
  random_tags = Tag.all.sample(rand(1..3))
  random_tags.each do |tag|
    post.tags << tag if post.tags.exclude?(tag)
  end
end

masashi_post = User.find_by(name: 'Masashi Watahiki').posts.first
%w[JavaScript HTML CSS].each do |tag_name|
  tag = Tag.find_by(name: tag_name)
  masashi_post.tags << tag if masashi_post.tags.exclude?(tag)
end

controllers_actions = {
  'users' => %w[index show],
  'posts' => %w[index show new create edit update destroy],
  'tags' => %w[index show]
}

User.where.not(id: [keito.id, masashi.id]).each do |user|
  controllers_actions.each do |controller, actions|
    actions.each do |action|
      Permission.create!(
        user: user,
        controller: controller,
        action: action
      )
    end
  end
end

[keito, masashi].each do |user|
  Permission.available_controllers.each do |controller|
    available_actions = Permission.available_actions(controller)
    available_actions.each do |action|
      Permission.create!(
        user: user,
        controller: controller,
        action: action
      )
    end
  end
end

User.where.not(id: [keito.id, masashi.id]).each do |user|
  rand(1..3).times do |i|
    start_time = Time.current + rand(-30..30).days + rand(9..17).hours
    user.events.create!(
      title: "Event #{i + 1} by #{user.name}",
      description: "Description for event #{i + 1}",
      start_at: start_time,
      end_at: start_time + rand(1..4).hours,
      location: %w[東京 大阪 名古屋 福岡 札幌].sample
    )
  end
end

[keito, masashi].each do |admin|
  5.times do |i|
    start_time = Time.current + rand(-10..30).days + rand(9..17).hours
    admin.events.create!(
      title: "Admin Event #{i + 1} by #{admin.name}",
      description: "Important event #{i + 1} details",
      start_at: start_time,
      end_at: start_time + rand(2..6).hours,
      location: 'GAオフィス'
    )
  end
end

User.where.not(id: [keito.id, masashi.id]).each do |user|
  rand(1..3).times do |i|
    user.purchase_histories.create!(
      name: "PurchaseHistory #{i + 1} by #{user.name}",
      price: rand(1000..10_000),
      purchase_date: Time.current - rand(1..30).days
    )
  end
end

[keito, masashi].each do |admin|
  5.times do |i|
    admin.purchase_histories.create!(
      name: "Admin PurchaseHistory #{i + 1} by #{admin.name}",
      price: rand(1000..10_000),
      purchase_date: Time.current - rand(1..30).days
    )
  end
end

categories = ['Books', 'Electronics', 'Office Supplies', 'Food & Beverages', 'Software']

User.where.not(id: [keito.id, masashi.id]).each do |user|
  rand(1..3).times do |i|
    UnnormalizedPurchaseHistory.create!(
      user_name: user.name,
      user_email: user.email,
      product_name: "Product #{i + 1} for #{user.name}",
      product_price: rand(1000..10_000),
      quantity: rand(1..5),
      category_name: categories.sample,
      purchase_date: Time.current - rand(1..30).days
    )
  end
end

[keito, masashi].each do |admin|
  5.times do |i|
    UnnormalizedPurchaseHistory.create!(
      user_name: admin.name,
      user_email: admin.email,
      product_name: "Admin Product #{i + 1} for #{admin.name}",
      product_price: rand(2000..20_000),
      quantity: rand(1..3),
      category_name: categories.sample,
      purchase_date: Time.current - rand(1..30).days
    )
  end
end

20.times do |i|
  product = Product.create!(
    name: "Product #{i + 1}",
    category: Product.categories.keys.sample
  )

  rand(1..3).times do |j|
    ProductSalesInfo.create!(
      product: product,
      price: rand(1000..10_000),
      effective_from: (j + 1).months.ago,
      discontinued: true
    )
  end

  ProductSalesInfo.create!(
    product: product,
    price: rand(1000..10_000),
    effective_from: Time.current,
    discontinued: false
  )
end

Product.find_each do |product|
  ActiveRecord::Base.transaction do
    Inventory.create!(
      product: product,
      quantity: rand(0..100)
    )
  end
end

User.find_each do |user|
  rand(1..5).times do
    ActiveRecord::Base.transaction do
      order = Order.new(
        user: user,
        order_date: rand(1..360).days.ago
      )

      rand(1..3).times do
        product = Product.all.sample
        current_price = product.product_sales_infos.current.first

        order.order_items.build(
          product_sales_info: current_price,
          quantity: rand(1..3)
        )
      end

      order.save!

      if rand < 0.2
        OrderCancel.create!(
          order: order,
          reason: %w[在庫切れ お客様都合 その他].sample
        )
      end
    end
  end
end

Order.find_each do |order|
  Shipment.create!(
    order: order,
    tracking_number: SecureRandom.hex(8).upcase,
    status: 'preparing'
  )
end
