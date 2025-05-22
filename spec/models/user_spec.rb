require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let!(:profile) { create(:profile, user: user) }
  let!(:api_token) { create(:api_token, user: user) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user.name = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without an email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'is not valid with an invalid email format' do
      user.email = 'invalid_email'
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      duplicate_user = user.dup
      duplicate_user.save
      expect(duplicate_user).not_to be_valid
    end

    it 'is not valid with a password shorter than 4 characters' do
      user.password = '123'
      expect(user).not_to be_valid
    end

    it 'is not valid without an occupation' do
      user.occupation = nil
      expect(user).not_to be_valid
    end
  end

  context 'enums' do
    it 'defines occupation enum with correct values' do
      expected_occupations = {
        'student' => 0,
        'employee' => 10,
        'self_employed' => 20,
        'unemployed' => 30,
        'other' => 40
      }
      expect(User.occupations).to eq(expected_occupations)
    end

    it 'allows setting and getting occupation' do
      user = build(:user, occupation: :student)
      expect(user.occupation).to eq('student')
      expect(user.student?).to be true

      user.occupation = :employee
      expect(user.occupation).to eq('employee')
      expect(user.employee?).to be true
    end

    it 'can save user with different occupations' do
      User.occupations.keys.each do |occupation|
        user = create(:user, occupation: occupation)
        expect(user.occupation).to eq(occupation)
        expect(user.send("#{occupation}?")).to be true
      end
    end
  end

  context 'associations' do
    it 'has one profile' do
      expect(user.profile).to eq(profile)
      expect(profile.user).to eq(user)
    end

    it 'has many posts' do
      post1 = create(:post, user: user)
      post2 = create(:post, user: user)
      expect(user.posts).to include(post1, post2)
      expect(post1.user).to eq(user)
      expect(post2.user).to eq(user)
    end

    it 'has one api_token' do
      expect(user.api_token).to be_present
      expect(user.api_token.user).to eq(user)
    end
  end
end
