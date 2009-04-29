module Kernel
  def _(msgid, options = {})
    I18n.t(msgid, { :default => msgid, :separator => '|' }.merge(options))
  end

  def sgettext(msgid, separator = '|')
    scope, msgid = I18n::Gettext.extract_scope(msgid, separator)
    I18n.t(msgid, :scope => scope, :default => msgid)
  end

  def pgettext(msgctxt, msgid, separator = I18n::Gettext::CONTEXT_SEPARATOR)
    sgettext([msgctxt, msgid].join(separator), separator)
  end

  def ngettext(msgid, msgid_plural, n = 1)
    nsgettext(msgid, msgid_plural, n, nil)
  end

  def nsgettext(msgid, msgid_plural, n = 1, separator = nil)
    scope, msgid = I18n::Gettext.extract_scope(msgid, separator)
    default = { :one => msgid, :other => msgid_plural }
    msgid = [msgid, I18n::Gettext::PLURAL_SEPARATOR, msgid_plural].join
    I18n.t(msgid, :default => default, :count => n, :scope => scope)
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../vendor/po_parser.rb')

module I18n
  module Gettext
    PLURAL_SEPARATOR  = "\001"
    CONTEXT_SEPARATOR = "\004"

    def self.extract_scope(msgid, separator = nil)
      scope = msgid.to_s.split(separator || '|')
      msgid = scope.pop
      [scope, msgid]
    end
  end

  @@plural_keys = { :en => [:one, :other] }
  def self.plural_keys(locale)
    @@plural_keys[locale] || @@plural_keys[:en]
  end

  module Backend
    class Gettext < Simple
      class PoData < Hash
        def set_comment(msgid_or_sym, comment)
          # ignore
        end
      end

      protected

        def load_po(filename)
          locale = File.basename(filename, '.po').to_sym
          data = parse(filename)
          data = normalize(locale, data)
          { locale => data }
        end

        def parse(filename)
          GetText::PoParser.new.parse(File.read(filename), PoData.new)
        end

        def normalize(locale, data)
          data.inject({}) do |result, (key, value)|
            key, value = normalize_pluralization(locale, key, value) if key.index("\000")
            result[key] = value
            result
          end
        end

        def normalize_pluralization(locale, key, value)
          # FIXME po_parser includes \000 chars that can not be turned into Symbols
          key = key.dup.gsub("\000", I18n::Gettext::PLURAL_SEPARATOR)

          keys = I18n.plural_keys(locale)
          values = value.split("\000")
          raise "invalid number of plurals: #{values.size}, keys: #{keys.inspect}" if values.size != keys.size

          result = {}
          values.each_with_index { |value, ix| result[keys[ix]] = value }
          [key, result]
        end
    end
  end
end
