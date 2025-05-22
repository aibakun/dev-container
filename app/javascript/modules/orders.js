import jquery from "jquery"
const $ = jquery

const OrderForm = {
  initialize: function() {
    $('#order-items').on('change', 'select', function() {
      const $select = $(this)
      const $row = $select.closest('tr')

      if ($select.val() && $row.is(':last-child')) {
        OrderForm.addNewRow($row)
      }
    })

    .on('change', 'input[type="number"]', function() {
      const $input = $(this)
      if (parseInt($input.val()) < 1) $input.val(1)
    })
  },

  addNewRow: function($row) {
    const index = $('.order-item').length
    const $newRow = $row.clone()

    $newRow.find('select, input').each(function() {
      const $input = $(this)
      $input
        .val($input.is('select') ? '' : 1)
        .attr('name', $input.attr('name').replace(/\[\d+\]/, `[${index}]`))
        .attr('id', ($input.is('select') ? 'product_select_' : 'quantity_input_') + index)
    })

    $row.parent().append($newRow)
  }
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', OrderForm.initialize)
} else {
  OrderForm.initialize()
}

document.addEventListener('turbo:load', OrderForm.initialize)

export const initializeOrderForm = OrderForm.initialize
