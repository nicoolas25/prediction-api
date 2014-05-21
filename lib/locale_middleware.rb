#
# This is a version of the rack locale middleware that dosn't rely on the i18n gem.
#
# It allow only a subset of locales
#

class LocaleMiddleware
  DEFAULT_LOCALE = 'en'

  def initialize(app)
    @app = app
  end

  def call(env)
    locale = env['rack.locale'] = accept_locale(env) || DEFAULT_LOCALE
    status, headers, body = @app.call(env)
    headers['Content-Language'] = locale
    [status, headers, body]
  end

  private

  def accept_locale(env)
    accept_langs = env['HTTP_ACCEPT_LANGUAGE']
    return if accept_langs.nil?

    languages = accept_langs.split(",").map do |l|
      l += ';q=1.0' unless l =~ /;q=\d+(?:\.\d+)?$/
      l.split(';q=')
    end

    languages = languages.select  { |(locale, _)| locale =~ /^(fr)|(en)|(es)|(pt)$/ }
    languages = languages.sort_by { |(_, qvalue)| qvalue.to_f }

    lang = languages.last.first

    lang == '*' ? nil : lang
  end
end
