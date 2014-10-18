class ActiveRecordFakeWithErrorOverride < ActiveRecordFake
  def self.asari_on_error(exception)
    false
  end
end