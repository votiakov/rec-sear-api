# == Schema Information
#
# Table name: app_versions
#
#  id         :uuid             not null, primary key
#  version    :string
#  kind       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppVersionSerializer < ResourceSerializer

  attributes  :id, :kind, :version, :created_at, :updated_at
end
