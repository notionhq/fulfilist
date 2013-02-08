class Ability
  include CanCan::Ability
  
  def initialize(user)
    user ||= User.new # guest teacher
    
    can :manage, User do |u|
      u == user
    end
    
    can :manage, Item do |item|
      item.list.user == user
    end
    
    can :create, Item
    
    can :claim, Item do |item|
      item.user != user
    end
    
    can :read, :all
    
  end
end