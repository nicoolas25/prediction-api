window.DATE_FORMAT = 'YYYY-MM-DD HH:mm'

token = api_url = null

addQuestionInit = ->
  return null unless $('#questions-new').length

  insertLocales = ($root, hash, type='label') ->
    $root.find("> fieldset > div.#{type}").each (_, block) ->
      $block = $(block)
      lang = $block.find('select.locale').val()
      text = $block.find("input.#{type}").val()
      hash[lang] = text

  $(document).on 'click', 'div.add a', ->
    $el = $(@).closest('.add')
    $bk = $el.prev()
    $cl = $bk.clone()
    $cl.find('input, select').val(null)
    $cl.insertAfter($bk)

  $(document).on 'click', 'div.remove a', ->
    $el = $(@).closest('div.remove').parent()
    if $el.prev().is('div.label, div.component, div.choice')
      $el.remove()
    else
      alert('Dernier de son genre...')

  $(document).on 'submit', 'form', (e) ->
    e.preventDefault()
    params = {labels: {}, components: [], expires_at: null}
    $form = $(@)

    expires_at = $form.find('> fieldset > input.expires_at').val()
    params.expires_at = expires_at

    insertLocales($form, params.labels)

    $form.find('> fieldset > div.component').each (_, component) ->
      componentHash = {labels: {}}
      $component = $(component)
      componentHash.kind = $component.find('select.kind').val()
      insertLocales($component, componentHash.labels)

      if componentHash.kind is '0' # choices
        componentHash.choices = {}
        insertLocales($component, componentHash.choices, 'choice')

      params.components.push(componentHash)

    $.ajax
      url: "http://#{api_url}/v1/admin/questions",
      type: 'POST'
      contentType: 'application/json',
      processData: false
      data: JSON.stringify
        token: $form.find('input.token').val()
        question: params
    .done ->
      alert('Done!')
    .fail ->
      console.log arguments
      alert('Fail!')

listQuestionsInit = ->
  $list = $('#questions-list')
  return null unless $list.length

  $.ajax
    url: "http://#{api_url}/v1/admin/questions"
    type: 'GET'
    data: { token: token }
  .done (questions) ->
    buffer = ''
    for question in questions
      buffer +=
        """
        <li class="question">
          <a href="/questions/#{question.id}?token=#{token}">#{question.labels.fr ? question.labels.en}</a>
          <span class="expires_at">#{moment(question.expires_at * 1000).format(DATE_FORMAT)}</span>
          <span class="stats participations">#{question.statistics.participations} participations</span>
          <span class="stats cristals">#{question.statistics.total} cistaux</span>
        </li>
        """
    $list.html(buffer)

listPlayersInit = ->
  $list = $('#players-list')
  return null unless $list.length

  $.ajax
    url: "http://#{api_url}/v1/admin/players"
    type: 'GET'
    data: { token: token }
  .done (players) ->
    buffer = ''
    for player in players
      buffer +=
        """
        <li class="player">
          <a href="/players/#{player.nickname}?token=#{token}">#{player.nickname}</a>
        </li>
        """
    $list.html(buffer)

detailsPlayersInit = ->
  return null unless $('#players-details').length

  nickname = $('meta[name=playerNickname]').prop('content')

  fetchPlayer = ->
    $.ajax
      url: "http://#{api_url}/v1/admin/players/#{nickname}"
      type: 'GET'
      data: { token: token }
    .done (player) ->
      # Set informations
      $('#informations .cristals').val(player.statistics.cristals)

  $(document).on 'click', 'form a', ->
    $form = $(this).closest('form')
    $.ajax
      url: "http://#{api_url}/v1/admin/players/#{nickname}"
      type: 'PUT'
      contentType: 'application/json'
      processData: false
      data: JSON.stringify
        token: token
        cristals: $form.find('input').val()
    .done ->
      alert('Done!')
      fetchPlayer()

  fetchPlayer()

detailsQuestionsInit = ->
  return null unless $('#questions-details').length

  questionId = $('meta[name=questionId]').prop('content')

  fetchQuestion = ->
    $.ajax
      url: "http://#{api_url}/v1/admin/questions/#{questionId}"
      type: 'GET'
      data: { token: token }
    .done (question) ->
      # Set informations
      $('#informations').html("""<span class="expires_at">Expiration #{moment(question.expires_at * 1000).format(DATE_FORMAT)}</span>""")

      # Set labels
      buffer = ''
      for locale, label of question.labels
        buffer += """<span class="label">#{label} <span class="locale">(#{locale})</span></span>"""
      $('#labels').html(buffer)

      # Set components
      buffer = '<div class="components">'
      for component in question.components
        buffer += """<div class="component #{component.kind}">"""

        # Display the labels
        buffer += '<div class="labels">'
        for locale, label of component.labels
          buffer += """<span class="label">#{label} <span class="locale">(#{locale})</span></span>"""
        buffer += '</div>'

        # Display the component's choices
        if component.choices?
          buffer += '<div class="choices">'
          for choice in component.choices
            buffer +=
              """
              <span class="choice" data-position="#{choice.position}">
                #{choice.position} - #{choice.label}
                <span class="locale">(#{choice.locale})</span>
              </span>
              """
          buffer += '</div>'

        # Allow to add an answer
        buffer += '<div class="answers">'
        buffer += '<label>Solution</label>'
        if component.valid_answer?
          buffer += """<input type="text" data-id="#{component.id}" value="#{component.valid_answer}" disabled="disabled" />"""
        else
          buffer += """<input type="text" data-id="#{component.id}" />"""
        buffer += '</div>'

        buffer += '</div>'
      buffer += '</div>'
      $('#components').html(buffer)

  $(document).on 'click', 'form a', ->
    components = {}
    $form = $(this).closest('form')
    $form.find('input').each ->
      $input = $(this)
      id = $input.data('id')
      answer = $input.val()
      components[id] = answer

    $.ajax
      url: "http://#{api_url}/v1/admin/questions/#{questionId}"
      type: 'PUT'
      contentType: 'application/json'
      processData: false
      data: JSON.stringify
        token: token
        components: components
    .done ->
      fetchQuestion()

  fetchQuestion()

$ ->
  # Set the api URL according to the host.
  if window.location.host is 'predictio.info'
    api_url = 'api.predictio.info'
  else
    api_url = window.location.host

  token = $('meta[name=token]').prop('content')

  addQuestionInit()
  listQuestionsInit()
  detailsQuestionsInit()
  listPlayersInit()
  detailsPlayersInit()
