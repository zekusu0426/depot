require 'test_helper'

class ProductTest < ActiveSupport::TestCase

  test "product attributes must not be empty" do
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    product = Product.new(title: "xxxxxxxxxxxx",
                          description: "yyy",
                          image_url: "zzz.jpg")

    product.price = 0
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join(';')

    product.price = 0.009
    assert product.invalid?
    assert_equal "must be greater than or equal to 0.01",
      product.errors[:price].join(';')

    product.price = 1
    assert product.valid?

    product.price = 0.01
    assert product.valid?
  end

  def new_product(image_url)
    Product.new(title: "My Book Title",
                description: "yyy",
                price: 1,
                image_url: image_url)
  end

  test "image_url" do
    ok = %w{ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg http://a.b.c/x/y/z/fred.gif}
    bad = %w{ fred.doc fred.gif/more fred.gif.more }

    ok.each do |name|
      assert new_product(name).valid?, "#{name} shouldn't be invalid"
    end

    bad.each do |name|
      assert new_product(name).invalid?, "#{name} shouldn't be valid"
    end
  end

  test "product is not valid without a unique title" do
    product = Product.new(title: products(:ruby).title,
                          description: "yyyyyyyyyyyyyy",
                          price: 1,
                          image_url: "fred.gif")

    assert !product.save
    assert_equal "has already been taken", product.errors[:title].join(';')
  end

  test "title minimum 10 characters" do
    product = products(:ruby)

    product.title = "123456789"
    assert product.invalid?
    assert product.errors[:title].join(";").include?("Title length over 10")

    product.title = "あいうえおかきくけ"
    assert product.invalid?

    product.title = "a b c d e f"
    assert product.valid?

    product.title = "1234567890"
    assert product.valid?

    # 全てが半角スペースの時は「空っぽ扱い」らしいよ！
    product.title = "          "
    assert product.invalid?, "#{product.title.size} characters"
    assert product.errors[:title].join(";").include?("can't be blank")

    # 全てが全角スペースの時も「空っぽ扱い」らしいよ！
    product.title = "　　　　　　　　　　"
    assert product.invalid?, "#{product.title.size} characters"

    # 1文字でもスペース以外が含まれていたらvalidらしいよ！
    product.title = "1         "
    assert product.valid?, "#{product.title.size} characters"
  end

end
