require "rails_helper"

RSpec.describe OrganizationPolicy, type: :policy do
  subject(:organization_policy) { described_class.new(user, organization) }

  let(:organization) { build_stubbed(:organization) }

  context "when user is not signed-in" do
    let(:user) { nil }

    it { within_block_is_expected.to raise_error(Pundit::NotAuthorizedError) }
  end

  context "when a non-org user" do
    let(:user) { build_stubbed(:user) }

    it { is_expected.to forbid_actions(%i[update analytics]) }
    it { is_expected.to permit_action(:create) }
  end

  context "when user is suspended" do
    let(:user) { build(:user, :suspended) }

    it { is_expected.to forbid_actions(%i[create update]) }
  end

  context "when user is an org admin of an org" do
    subject(:organization_policy) { described_class.new(user, org) }

    let(:user) { create(:user) }
    let(:org)  { create(:organization) }

    before do
      create(:organization_membership, user: user, organization: org, type_of_user: "admin")
    end

    it { is_expected.to permit_actions(%i[analytics update]) }
  end

  context "when user is a member of an org org" do
    subject(:organization_policy) { described_class.new(user, org) }

    let(:user) { create(:user) }
    let(:org)  { create(:organization) }

    before do
      create(:organization_membership, user: user, organization: org)
    end

    it { is_expected.to permit_actions(%i[analytics]) }
  end

  context "when user is an org admin of another org" do
    subject(:organization_policy) { described_class.new(user, new_org) }

    let(:user) { create(:user) }
    let(:org)  { create(:organization) }
    let(:new_org) { build_stubbed(:organization) }

    before { create(:organization_membership, user: user, organization: org, type_of_user: "admin") }

    it { is_expected.to forbid_actions(%i[analytics update]) }
  end
end
