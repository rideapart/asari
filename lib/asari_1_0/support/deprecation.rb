module Asari::Support

  # Deprecation helpers
  module Deprecation

    # Display a deprecation warning
    # @param [String] old - name of deprecated method
    # @param [String] new - name of the desired replacement
    def deprecation_warning(old, new)
      warn "[Deprecation] #{old} is deprecated" + (new ? ", please use #{new}\n" : "\n")
    end

    # Define a deprecated alias for a method
    # @param [Symbol] old - name of method to define
    # @param [Symbol] new - name of method to alias
    def deprecated_alias(old, new)
      define_method(old) do |*args, &block|
        deprecation_warning old, new
        send new, *args, &block
      end
    end

    # Deprecate a defined method
    # @param [Symbol] old - name of deprecated method
    # @param [Symbol] new - name of the desired replacement
    def deprecate(old, new = nil)
      old_holder = :"#{old}_without_deprecation"
      alias_method old_holder, old

      define_method(old) do |*args, &block|
        deprecation_warning(old, new)
        send old_holder, *args, &block
      end
    end

  end
end