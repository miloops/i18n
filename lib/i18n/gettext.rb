module Kernel
  def _(msgid)
    I18n.t(msgid, :default => msgid, :separator => '|')
  end
  
  def sgettext(msgid, separator = '|')
    scope = msgid.to_s.split(separator)
    msgid = scope.pop
    I18n.t(msgid, :scope => scope, :default => msgid)
  end
  
  def pgettext(msgctxt, msgid, separator = "\004")
    sgettext([msgctxt, msgid].join(separator), separator)
  end
  
  def ngettext(msgid, msgid_plural, n = 1)
    I18n.t(msgid, :default => { :one => msgid, :other => msgid_plural }, :count => n)
  end
  
  def nsgettext(msgid, msgid_plural, n = 1, separator = "|")
    scope = msgid.to_s.split(separator)
    msgid = scope.pop
    I18n.t(msgid, :default => { :one => msgid, :other => msgid_plural }, :count => n)
  end
end

