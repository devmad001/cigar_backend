#= require active_admin/base
#= require activeadmin_addons/all
#= require JavaScript-Load-Image/load-image.all.min
#= require inputmask/dist/jquery.inputmask.js
#= require activeadmin_reorderable

$ ->
  $('.inputs').on 'change', '.image-input', (e)->
    input = e.currentTarget
    preview = $(input).siblings('.inline-hints').find('img')

    makePreview = (img)->
      preview.attr 'src', img.toDataURL()

    if input.files && input.files[0]
      loadImage input.files[0], makePreview, { orientation: true }

    if input.files[0].size > 1024 * 2e6
      alert 'File size more than 200Mb'

  Inputmask().mask(document.querySelectorAll('input'))
