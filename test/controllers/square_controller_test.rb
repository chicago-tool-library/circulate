require "test_helper"

class SquareControllerTest < ActionDispatch::IntegrationTest
  def payment_updated_payload
    {merchant_id: "HE0AV82NDSPXY",
     type: "payment.updated",
     event_id: "71c54eb8-f70a-3ef5-aebd-6093457e6f32",
     created_at: "2024-06-25T05:40:17.581Z",
     data: {
       type: "payment",
       id: "jDLRuBLA2KPl7JYORsmJhxHKUvGZY",
       object: {
         payment: {
           amount_money: {
             amount: 5500,
             currency: "USD"
           },
           application_details: {
             application_id: "sandbox-sq0idb-lky4CaPAWmDnHY3YtYxINg",
             square_product: "ECOMMERCE_API"
           },
           capabilities: [
             "EDIT_AMOUNT_UP",
             "EDIT_AMOUNT_DOWN",
             "EDIT_TIP_AMOUNT_UP",
             "EDIT_TIP_AMOUNT_DOWN"
           ],
           created_at: "2024-06-25T05:40:16.194Z",
           external_details: {
             source: "Developer Control Panel",
             type: "CARD"
           },
           id: "jDLRuBLA2KPl7JYORsmJhxHKUvGZY",
           location_id: "X9QSBEAF8RK29",
           note: "Chicago Tool Library annual membership",
           order_id: "bfE82Bs4tWAEyTrcoxIpVl42Qe4F",
           receipt_number: "jDLR",
           receipt_url: "https://squareupsandbox.com/receipt/preview/jDLRuBLA2KPl7JYORsmJhxHKUvGZY",
           source_type: "EXTERNAL",
           status: "COMPLETED",
           total_money: {
             amount: 5500,
             currency: "USD"
           },
           updated_at: "2024-06-25T05:40:16.335Z",
           version: 1
         }
       }
     }}
  end

  test "rejects requests that aren't signed correctly" do
    assert_no_enqueued_jobs do
      post square_callback_url, params: payment_updated_payload, headers: {
        "X-SQUARE-HMACSHA256-SIGNATURE": "invalid-sgnature"
      }

      assert_equal 401, response.status
    end
  end

  test "handles payment updates" do
    assert_enqueued_with(job: SquarePaymentJob, args: [{order_id: "bfE82Bs4tWAEyTrcoxIpVl42Qe4F"}]) do
      post square_callback_url, params: payment_updated_payload, headers: {
        "X-SQUARE-HMACSHA256-SIGNATURE": "s2TfTqnEVXKbXile3L/LfCd/MMhcQXRHQXROromxPDI="
      }

      assert response.ok?
    end
  end
end
