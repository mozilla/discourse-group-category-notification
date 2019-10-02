# name: group-category-notification
# about: Enables automatic subscription to categories based on group membership
# version: 0.0.1
# authors: Leo McArdle
# url: https://github.com/mozilla/discourse-group-category-notification

module ::GroupCategoryNotification
  def self.add(group, category)
    group.custom_fields["default_categories_watching"] =
      Array(group.custom_fields["default_categories_watching"]) | [category.id]
    group.users.each do |user|
      subscribe_user(user, category.id)
    end
    group.save_custom_fields
  end

  def self.remove(group, category)
    group.users.each do |user|
      unsubscribe_user(user, category.id)
    end
    group.custom_fields["default_categories_watching"] -= [category.id]
    group.save_custom_fields
  end

  def self.subscribe_user(user, category_id)
    level = CategoryUser.notification_levels[:watching]
    CategoryUser.set_notification_level_for_category(user, level, category_id)
  end

  def self.unsubscribe_user(user, category_id)
    level = CategoryUser.notification_levels[:regular]
    CategoryUser.set_notification_level_for_category(user, level, category_id)
  end
end

after_initialize do
  Group.register_custom_field_type "default_categories_watching", [:integer]

  DiscourseEvent.on(:user_added_to_group) do |user, group|
    categories = group.custom_fields["default_categories_watching"]
    return unless categories
    categories.each do |category_id|
      GroupCategoryNotification.subscribe_user(user, category_id)
    end
  end

  DiscourseEvent.on(:user_removed_from_group) do |user, group|
    categories = group.custom_fields["default_categories_watching"]
    return unless categories
    categories.each do |category_id|
      GroupCategoryNotification.unsubscribe_user(user, category_id)
    end
  end

  DiscourseEvent.on(:group_destroyed) do |group|
    categories = group.custom_fields["default_categories_watching"]
    return unless categories
    categories.each do |category_id|
      group.users.each do |user|
        GroupCategoryNotification.unsubscribe_user(user, category_id)
      end
    end
  end
end
