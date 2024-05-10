# == Schema Information
#
# Table name: articles
#
#  id           :bigint           not null, primary key
#  title        :string
#  image        :string
#  body         :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  article_type :integer
#
class Article < ApplicationRecord
  INSTRUCTION = <<STRING
    <ul>
      <li># text - <h1>text</h1></li>
      <li>## text - <h2>text</h2></li>
      <li>### text - <h3>text</h3></li>
      <li>...</li>
      <li>###### text - <h6>text</h6></li>
      <li>**text** - <strong>bold</strong></li>
      <li><strong>*</strong>text<strong>* - </strong><em>italic</em></li>
      <li>~~text~~ - <s>text</s></li>
      <li>__text__ - <u>text</u></li>
      <li>* - list item</li>
      <li><strong>%{attachment_1}</strong> - insert attachment</li>
      <li>[text link](https://example.com) - insert link</li>
    </ul>
STRING

  validates :title, :body, :image, :article_type, presence: true

  mount_uploader :image, ImageUploader

  has_many :attachments, as: :attachable, dependent: :destroy

  accepts_nested_attributes_for :attachments, allow_destroy: true

  enum article_type: %i(blog news)

  def compile_body
    _body = self.body.to_s

    self.attachments.each do |attachment|
      _body.gsub!(
          /%{\s*attachment_#{ attachment.position }\s*}/,
          "<div style=\"display: flex; justify-content: center;\"><#{ attachment.image? ? 'img' : 'video' } width=\"500\" controls "\
          "src=\"#{ attachment.attachment.url }\">#{ attachment.video? ? '</video>' : '' }</div>"
      ) if attachment.attachment.present?
    end

    _body = Redcarpet::Markdown
                .new(
                  Redcarpet::Render::HTML,
                  autolink: true,
                  tables: true,
                  strikethrough: true,
                  highlight: true,
                  quote: true,
                  footnotes: true,
                  underline: true
                )
                .render(_body)

    self.attachments.each do |attachment|
      _body.gsub!(
          /%{\s*attachment_#{ attachment.position }\s*}/,
          "<div><#{ attachment.image? ? 'img' : 'video' } width=\"300\" controls "\
          "src=\"#{ attachment.attachment.url }\">#{ attachment.video? ? '</video>' : '' }</div>"
      ) if attachment.attachment.present?
    end

    _body
  end

  def name
    self.title
  end

  def to_s
    self.id.to_s
  end
end
