insertLocales = ($root, hash, type='label') ->
  $root.find("> fieldset > div.#{type}").each (_, block) ->
    $block = $(block)
    lang = $block.find('select.locale').val()
    text = $block.find("input.#{type}").val()
    hash[lang] = text

$ ->
  $(document).on 'click', 'div.add button', ->
    $el = $(@).closest('.add')
    $bk = $el.prev()
    $cl = $bk.clone()
    $cl.find('input, select').val(null)
    $cl.insertAfter($bk)

  $(document).on 'click', 'div.remove button', ->
    $el = $(@).closest('div.remove').parent()
    if $el.prev().is('div.label, div.component, div.choice')
      $el.remove()
    else
      alert('Dernier de son genre...')

  $(document).on 'submit', 'form', (e) ->
    params = {labels: {}, components: []}
    $form = $(@)
    insertLocales($form, params.labels)

    $form.find('> fieldset > div.component').each (_, component) ->
      componentHash = {labels: {}}
      $component = $(component)
      componentHash.kind = $component.find('select.kind').val()
      insertLocales($component, componentHash.labels)
      if componentHash.kind is 'choices'
        componentHash.choices = {}
        insertLocales($component, componentHash.choices, 'choice')
      params.components.push(componentHash)

    console.log params
    e.preventDefault()
