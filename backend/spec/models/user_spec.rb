require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe 'validations' do
    context 'email' do
      it 'should be valid with valid email' do
        user.email = 'test@example.com'
        expect(user).to be_valid
      end

      it 'blank email should be invalid' do
        user.email = ''
        expect(user).to be_invalid
      end

      it 'should be invalid with an invalid format' do
        user.email = 'invalid-email'
        expect(user).to be_invalid
      end
    end

    context 'password' do
      it 'should be valid with password' do
        user.password = 'password123'
        user.password_confirmation = 'password123'
        expect(user).to be_valid
      end

      it 'should be invalid with password confirmation mismatch' do
        user.password = 'password123'
        user.password_confirmation = 'password456'
        expect(user).to be_invalid
      end

      it 'should be invalid with blank password' do
        user.password = ''
        user.password_confirmation = ''
        expect(user).to be_invalid
      end

      it 'should be invalid with blank password confirmation' do
        user.password = 'password123'
        user.password_confirmation = ''
        expect(user).to be_invalid
      end

      it 'should be invalid with blank password and password confirmation' do
        user.password = ''
        user.password_confirmation = ''
        expect(user).to be_invalid
      end
    end
  end
end
