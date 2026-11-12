class Document < ApplicationRecord
  # A doc's own link, as Share → Copy link gives it. Doc IDs run to 44
  # characters; the length floor turns away "Publish to web" links
  # (/document/d/e/2PACX-.../pub), whose short "e" segment isn't an ID.
  GOOGLE_DOC_URL = %r{\Ahttps://docs\.google\.com/document/d/([\w-]{25,})(?:[/?#]|\z)}

  has_rich_text :body

  validates :name, :summary, presence: true
  validates :google_doc_url, format: {with: GOOGLE_DOC_URL, message: "should be a Google Docs link, starting with https://docs.google.com/document/d/"}, allow_blank: true

  normalizes :google_doc_url, with: ->(url) { url.strip.presence }

  enum :code, {
    agreement: "agreement",
    code_of_conduct: "code_of_conduct",
    borrow_policy: "borrow_policy"
  }, validate: true

  acts_as_tenant :library

  def to_param
    code
  end

  # When staff keep a document in Google Docs, members see that doc embedded
  # in place of the body stored here. The doc has to be shared so anyone with
  # the link can view it, or members get Google's "request access" screen.
  def google_doc?
    google_doc_id.present?
  end

  # Google's /preview view drops the editor toolbar and, unlike "Publish to
  # web", works for any doc shared by link without an extra step in Google.
  def google_doc_embed_url
    "https://docs.google.com/document/d/#{google_doc_id}/preview" if google_doc?
  end

  private

  def google_doc_id
    google_doc_url&.match(GOOGLE_DOC_URL)&.captures&.first
  end
end
