jQuery ->
  $(".product_image_option").live 'click', ->
    src = $(this).attr("src")
    $(".product_image_option").removeClass("selected")
    $(this).addClass("selected")
    $(".final_product_image").val(src)
    
  $("#find-new-item-submit").live 'click', ->
    $(this).closest("form").css("opacity", "0")
    $(".show-hide").fadeIn()
  
  $("#replace-image").live 'click', (e) ->
      e.preventDefault()
      $(".file_field_wrapper").find("input").click()
  
  $(".dismiss-url").live 'click', (e) ->
    e.preventDefault()
    $("#new_item_link").show();
    $("#new_item").remove();
    $(".new_item_container").removeClass("pop_out");
    $(".mask").fadeOut(); 
  
  $(".check-mark").live 'click', ->
    if($(".claim.sign_up").length > 0)
      $(this).closest(".claim").find(".fb-sign-in").click()
    else
      $(this).closest(".claim").find("input[type=submit]").click()
  
  # unless($(".inner_wrapper").length > 0)
  #   $(".container").height($(window).height())
      
  if($(".user_dashboard").length > 0)
    $(".user_dashboard").css("right", "-300px")
  
    $(".open_dash").live 'click', (e) ->
      $(".mask").fadeIn()     
      $(".user_dashboard").css("right", "0px")
    $(".close_dash").live 'click', (e) ->
      # dashHeight = $(".user_dashboard").height()
      #       dashHeight = "-" + dashHeight + "px"
      $(".user_dashboard").css("right", "-300px")
      $(".mask").fadeOut()