class PhoneNumberValidator
  attr_reader :validator

  def initialize(validator: Phony)
    @validator = validator
  end

  def valid?(value)
    return false if value.starts_with?("0")
    # To drop Phone number validation - Accept Extensions
    return true
    # validator.plausible?(value)
  end
end
