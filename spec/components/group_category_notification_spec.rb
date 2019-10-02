require "rails_helper"

describe "group-category-notification plugin" do
  let(:user) { Fabricate(:user) }
  let(:group) { Fabricate(:group) }
  let(:category1) { Fabricate(:category) }
  let(:category2) { Fabricate(:category) }
  before do
    GroupCategoryNotification.add(group, category1)
  end

  context "when user is added to group" do
    it "subscribes user to group's categories" do
      group.add(user)
      category_user = CategoryUser.where(category: category1, user: user).first
      expect(category_user).to be
      expect(category_user.notification_level).to eq CategoryUser.notification_levels[:watching]
    end
  end

  context "when user is removed from group" do
    before { group.add(user) }

    it "unsubscribes user from group's categories" do
      group.remove(user)
      category_user = CategoryUser.where(category: category1, user: user).first
      expect(category_user).to be
      expect(category_user.notification_level).to eq CategoryUser.notification_levels[:regular]
    end
  end

  context "when category is added to group categories watching" do
    before { group.add(user) }

    it "subscribes users in the group" do
      GroupCategoryNotification.add(group, category2)
      category_user = CategoryUser.where(category: category2, user: user).first
      expect(category_user).to be
      expect(category_user.notification_level).to eq CategoryUser.notification_levels[:watching]
    end

    context "and a user has already unsubscribed from one of the other categories" do
      it "doesn't resubscribe the other category" do
        CategoryUser.where(category: category1, user: user).destroy_all
        GroupCategoryNotification.add(group, category2)
        category_users = CategoryUser.where(user: user)
        expect(category_users.count).to eq 1
      end
    end
  end

  context "when category is removed from group categories watching" do
    before { group.add(user) }

    it "unsubscribes users in the group" do
      GroupCategoryNotification.remove(group, category1)
      category_user = CategoryUser.where(category: category1, user: user).first
      expect(category_user).to be
      expect(category_user.notification_level).to eq CategoryUser.notification_levels[:regular]
    end

    context "and a user has already unsubscribed from one of the other categories" do
      it "doesn't resubscribe the other category" do
        GroupCategoryNotification.add(group, category2)
        CategoryUser.where(category: category2, user: user).destroy_all
        GroupCategoryNotification.remove(group, category1)
        category_users = CategoryUser.where(user: user)
        expect(category_users.count).to eq 1
      end
    end
  end

  context "when a category is deleted" do
    before { group.add(user) }

    it "unsubscribes users in the group" do
      group.destroy!
      category_user = CategoryUser.where(category: category1, user: user).first
      expect(category_user).to be
      expect(category_user.notification_level).to eq CategoryUser.notification_levels[:regular]
    end
  end
end
