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
    .then ->
      alert('Done!')
    , ->
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

  $template = $list.find('.player.template')
  $template.removeClass('template')
  $template.detach()

  $.ajax
    url: "http://#{api_url}/v1/admin/players"
    type: 'GET'
    data: { token: token }
  .done (players) ->
    buffer = ''
    for player in players
      $clone    = $template.clone()
      $id       = $clone.find('.player-id')
      $nick     = $clone.find('a.nickname')
      $cristals = $clone.find('.cristals')
      $auth     = $clone.find('.last_auth')

      $id.html(player.id)
      $nick.html(player.nickname)
      $nick.prop('href', "/players/#{player.nickname}?token=#{token}")
      $cristals.html(player.cristals)
      $auth.html(moment(player.last_authentication_at * 1000).format(DATE_FORMAT))

      buffer += $clone[0].outerHTML

    $list.find('.players').html(buffer)

detailsPlayersInit = ->
  $details = $('#players-details')
  return null unless $details.length

  $social = $details.find('.social-association')
  $social.detach()

  nickname = $('meta[name=playerNickname]').prop('content')

  fetchPlayer = ->
    $.ajax
      url: "http://#{api_url}/v1/admin/players/#{nickname}"
      type: 'GET'
      data: { token: token }
    .done (player) ->
      $details.find('input.cristals').val(player.cristals)
      $details.find('input.nickname').val(player.nickname)
      $details.find('input.fullname').val("#{player.first_name} #{player.last_name}")
      $details.find('input.friends').val(player.statistics.friends)
      $details.find('input.predictions').val(player.statistics.predictions)
      $details.find('input.last_auth').val(moment(player.last_authentication_at * 1000).format(DATE_FORMAT))

      buffer = ''
      for social in player.social
        $clone = $social.clone()
        $clone.find('.provider').attr('value', social.provider)
        $clone.find('.social-id').attr('value', social.id)
        $clone.find('.email').attr('value', social.email)
        $clone.find('.avatar').prop('src', social.avatar_url)
        buffer += $clone[0].outerHTML
      $details.find('.social-associations').html(buffer)


  $(document).on 'submit', 'form', (event) ->
    event.preventDefault()

    $.ajax
      url: "http://#{api_url}/v1/admin/players/#{nickname}"
      type: 'PUT'
      contentType: 'application/json'
      processData: false
      data: JSON.stringify
        token: token
        cristals: $details.find('input.cristals').val()
    .done ->
      alert('Done!')
      fetchPlayer()

  fetchPlayer()

detailsQuestionsInit = ->
  $details = $('#questions-details')
  return null unless $details.length

  # Fetch templates
  $labelTemplate           = $details.find('div.question-label').detach()
  $componentLabelTemplate  = $details.find('div.component-label').detach()
  $componentChoiceTemplate = $details.find('div.component-choice').detach()
  $componentTemplate       = $details.find('div.question-component').detach()

  questionId = $('meta[name=questionId]').prop('content')

  fetchQuestion = ->
    $.ajax
      url: "http://#{api_url}/v1/admin/questions/#{questionId}"
      type: 'GET'
      data: { token: token }
    .done (question) ->
      # Set informations
      $details.find('.reveals_at').val(moment(question.reveals_at * 1000).format(DATE_FORMAT))
      $details.find('.expires_at').val(moment(question.expires_at * 1000).format(DATE_FORMAT))

      # Set labels
      $details.find('.question-labels > .question-label').remove()
      buffer = ''
      for locale, label of question.labels
        $clone = $labelTemplate.clone()
        $clone.find("select.locale option[value=#{locale}]").attr('selected', true)
        $clone.find('input.question-label').attr('value', label)
        buffer += $clone[0].outerHTML
      $details.find('.question-labels').append(buffer)

      # Set components
      $details.find('.question-components > .question-component').remove()
      buffer = ''
      for component in question.components
        console.log component
        $clone = $componentTemplate.clone()

        # Set type and solution field
        kind = if component.kind is 'choices' then '0' else '1'
        $clone.find("select.kind option[value=#{kind}]").attr('selected', true)
        $solution = $clone.find('input.solution')
        if component.valid_answer?
          $solution.attr('value', component.valid_answer)
          $solution.attr('disabled', 'disabled')
        else
          $solution.attr('data-id', component.id)

        # Set labels
        labelBuffer = ''
        for locale, label of component.labels
          $labelClone = $componentLabelTemplate.clone()
          $labelClone.find("select.locale option[value=#{locale}]").attr('selected', true)
          $labelClone.find('input.component-label').attr('value', label)
          labelBuffer += $labelClone[0].outerHTML
        $clone.find('.component-labels').append(labelBuffer)

        # Set component's choices
        if component.choices?
          locale = component.choices[0].locale
          choiceBuffer = ''
          for choice in component.choices
            if choice.locale is locale
              $choiceClone = $componentChoiceTemplate.clone()
              $choiceClone.find('input.component-choice').attr('value', choice.label)
              $choiceClone.find('button.position').html(choice.position)
              choiceBuffer += $choiceClone[0].outerHTML
          $clone.find('.component-choices').append(choiceBuffer)

        buffer += $clone[0].outerHTML
      $details.find('.question-components').append(buffer)


  $(document).on 'click', '.position', (event) ->
    event.preventDefault()

    $btn = $(this)
    $sol = $btn.closest('.question-component').find('.solution')
    $sol.val($btn.html())

  $(document).on 'submit', 'form', (event) ->
    event.preventDefault()

    components = {}
    $form = $(this)
    $form.find('input.solution').each ->
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
    .then ->
      alert('Done!')
      fetchQuestion()
    , ->
      console.log arguments
      alert('Failed! See the console for more information.')

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
