module Common
  class StringUtils
    class << self
      def parse_wildcards(string)
        matching_parts = string.split('*', -1).collect { |part| Regexp.escape(part) }
        /\A#{matching_parts.join(".*")}\z/
      end
    end
  end
end
