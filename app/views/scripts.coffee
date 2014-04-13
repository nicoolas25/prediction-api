window.DATE_FORMAT = 'YYYY-MM-DD HH:mm'

token = api_url = null

cropInit = ->
  updateSelection = (crop) ->
    url = $('#image-url').val()
    label = "#{url}!#{crop.w}!#{crop.x}!#{crop.y}!#{crop.x2}!#{crop.y2}"
    $('#image-label').html(label)

  jCropApi = null

  cropImage = ->
    $('#image-crop').Jcrop({
      onChange: updateSelection,
      onSelect: updateSelection,
      aspectRatio: 1}, -> jCropApi = this)

  cropImage()

  $('#image-url').on 'change', ->
    jCropApi.destroy()
    $('#image-crop').prop('src', @value)
    cropImage()


addQuestionInit = ->
  return null unless $('#questions-new').length

  cropInit()

  $('.input-group.date').datetimepicker
    language: 'fr'
    format: "YYYY-MM-DD HH:mm:00 +0000"

  $(document).on 'click', 'button.add', (event) ->
    event.preventDefault()
    $btn   = $(@)
    sect   = $btn.data('section')
    $bloc  = $btn.closest('.row').next("div.#{sect}")
    $clone = $bloc.clone()
    $clone.find('input, select').val(null)
    $clone.insertBefore($bloc)

  $(document).on 'click', 'button.remove', (event) ->
    event.preventDefault()

    $btn  = $(@)
    sect  = $btn.data('section')
    sel   = "div.#{sect}"
    $bloc = $btn.closest(sel)
    if $bloc.prev().is(sel) or $bloc.next().is(sel)
      $bloc.remove()
    else
      alert('Vous devez avoir au moins un element de ce type.')


  insertLocales = ($root, object, type) ->
    $root.find("div.#{type}").each (_, block) ->
      $block = $(block)
      lang = $block.find('select.locale').val()
      text = $block.find("input.#{type}").val()
      object[lang] = text

  $(document).on 'submit', 'form', (event) ->
    event.preventDefault()

    params = {labels: {}, components: [], expires_at: null, reveals_at: null}
    $form = $(@)

    params.expires_at = $form.find('input.expires_at').val()

    params.reveals_at = $form.find('input.reveals_at').val()

    insertLocales($form, params.labels, 'question-label')

    $form.find('.question-component').each (_, component) ->
      $component = $(component)
      componentHash = {labels: {}}
      componentHash.kind = $component.find('select.kind').val()
      insertLocales($component, componentHash.labels, 'component-label')

      if componentHash.kind is '0' # choices
        componentHash.choices = {}
        insertLocales($component, componentHash.choices, 'component-choice')

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
      alert('Failed! See the console for more information.')

listQuestionsInit = ->
  $list = $('#questions-list')
  return null unless $list.length

  $template = $list.find('.question.template')
  $template.removeClass('template')
  $template.detach()

  $.ajax
    url: "http://#{api_url}/v1/admin/questions"
    type: 'GET'
    data: { token: token }
  .done (questions) ->
    buffer = ''
    for question in questions
      $clone    = $template.clone()
      $title    = $clone.find('a.title')
      $reveals  = $clone.find('.reveals_at')
      $expires  = $clone.find('.expires_at')
      $cristals = $clone.find('.cristals')

      $title.html(question.labels.fr ? question.labels.en)
      $title.prop('href', "/questions/#{question.id}?token=#{token}")
      $reveals.html(moment(question.reveals_at * 1000).format(DATE_FORMAT))
      $expires.html(moment(question.expires_at * 1000).format(DATE_FORMAT))
      $cristals.html(question.statistics.total)

      buffer += $clone[0].outerHTML

    $list.find('.questions').html(buffer)

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
      $('#informations').html(
        """
        <span class="reveals_at">Visible #{moment(question.reveals_at * 1000).format(DATE_FORMAT)}</span>
        <span class="expires_at">Expiration #{moment(question.expires_at * 1000).format(DATE_FORMAT)}</span>
        """)

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
