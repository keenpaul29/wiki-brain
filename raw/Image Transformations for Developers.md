---
title: "Image Transformations for Developers"
source: "https://cloudinary.com/documentation/image_transformations"
author:
published:
created: 2026-06-06
description: "Learn how to dynamically transform images with one line of code: crop, resize, add borders and background, face detection, rich image effects, and more."
tags:
  - "clippings"
---
> ## Documentation Index
> 
> Fetch the complete documentation index at: [https://cloudinary.com/documentation/llms.txt](https://cloudinary.com/documentation/llms.txt)
> 
> Use this file to discover all available pages before exploring further.

## Image transformations

Last updated: Jun-03-2026

Cloudinary's dynamic URL **transformations** enable you to programmatically generate multiple variations of your high quality original images on the fly, without the need for graphic designers and fancy editing tools.

You can build these URLs manually in your code, or take advantage of [Cloudinary's SDKs](https://cloudinary.com/documentation/cloudinary_sdks), which enable you to write your transformation code using intuitive syntax designed for your preferred programming language or framework and let the SDK automatically build these URLs for you.

Important

Your account's pricing plan is in part dependent on the total number of **transformation operations** performed during a billing cycle. These are primarily counted when Cloudinary generates a new 'derived asset' from an asset based on a transformation URL. For complete details, see [How are transformations counted?](https://cloudinary.com/documentation/transformation_counts)

Here are just a few examples of some popular use cases that you can accomplish on the fly by combining Cloudinary transformations. Click each image to see the URL parameters applied in each case:

![Auto-crop profile photos](https://res.cloudinary.com/demo/image/upload/ar_1.0,c_thumb,g_face,w_0.6,z_0.7/r_max/co_black,e_outline/co_dimgrey,e_shadow,x_30,y_40/c_scale,h_250/dpr_2.0/f_auto/q_auto/actor.png)

Auto-crop profile photos

![Pixelate detected faces](https://res.cloudinary.com/demo/image/upload/l_docs:academy-award/c_scale,fl_relative,h_0.6/c_crop,g_auto,h_0.9,w_0.7/fl_layer_apply,g_south_east/co_white,l_text:AlexBrush-Regular.ttf_250:James%20Stewart%20/co_black,e_outline/fl_layer_apply,g_south,x_30,y_30/c_scale,h_250/dpr_2.0/f_auto/q_auto/actor.jpg)

Pixelate detected faces

![Displace images on products](https://res.cloudinary.com/demo/image/upload/e_cartoonify/a_10/e_brightness:20/c_scale,h_250/dpr_2.0/f_auto/q_auto/actor.jpg)

Displace images on products

See also

[Video Transformations](https://cloudinary.com/documentation/video_manipulation_and_delivery)

## Overview

Cloudinary allows you to easily transform your images on the fly to any required format, style and dimension, and apply effects and other visual enhancements. You can also optimize your images to deliver them with minimal file size alongside high visual quality for an improved user experience and minimal bandwidth. You can do all of this by implementing dynamic image transformation and delivery URLs. Your transformed images are then delivered to your users through a fast CDN with optimized caching.

With image transformations, you can:

- Deliver images using the [image format](https://cloudinary.com/documentation/image_format_support) that fits your needs.
- [Resize and crop](https://cloudinary.com/documentation/resizing_and_cropping) your images to the required dimensions using different scaling and cropping techniques, or use our smart cropping techniques, including [face-detection](https://cloudinary.com/documentation/face_detection_based_transformations) or [auto-gravity](https://cloudinary.com/documentation/resizing_and_cropping#automatic_cropping_g_auto) for cropping to focus on the most relevant parts of a photo.
- Generate a new image by [layering](https://cloudinary.com/documentation/layers) other images or text on your base image.
- Apply a variety of [effects, filters, and other visual enhancements](#effects_and_artistic_enhancements) to help your image achieve the desired impact.
- And much more.... See [Transformation Types](https://cloudinary.com/documentation/image_transformation_types) for a listing of many different types of transformations you can apply with links to details.

Related topics

The rest of this page describes the basics of working with Cloudinary image transformations.

The other pages in this guide provide details and use-case examples on the various types of image transformations you can apply to your images.

The [Transformation URL API Reference](https://cloudinary.com/documentation/transformation_reference) details every transformation parameter available for both images and videos.

Tips

- Usage limits for uploading, transforming and delivering files depend on your Cloudinary [plan](https://cloudinary.com/pricing). For details, check the **Account** tab in your Cloudinary Console **Settings**.
- For additional information on how your overall account usage is calculated (including storage and bandwidth), see the [Cloudinary Pricing](https://cloudinary.com/pricing) page and this [FAQ section](https://cloudinary.com/documentation/developer_onboarding_faq#account_usage_and_monitoring).
- You can set your email preferences to receive [notifications regarding your account usage](https://cloudinary.com/documentation/dam_admin_usage_data#usage_notifications).
- You can view an asset's derived assets from the **Derived Assets** tab of the Manage page in the Media Library. This can help you manage transformation usage, for example by reusing existing derived versions instead of generating new ones.
	For more information, see [Derived assets](https://cloudinary.com/documentation/media_library_for_developers) on the *Media Library for developers* page.

On this page:

### Quick example

Below you can see the transformation URL and corresponding SDK code for generating an image with several transformation parameters applied:

- Scales and tightly crops the image to fit into a 200px x 200px square, centering on the auto-detected face: `/c_thumb,g_face,h_200,w_200/`
- Rounds the corners to a circle: `/r_max/`
- Converts and delivers the image in the best transparent format for the requesting browser. For example, webp or avif: `/f_auto/`

```
https://res.cloudinary.com/demo/image/upload/c_thumb,g_face,h_200,w_200/r_max/f_auto/woman-blackdress-stairs.png
```

[

Open In Studio

](https://tx-studio.cloudinary.com/?transformationString=c_thumb%2Cg_face%2Ch_200%2Cw_200%2Fr_max%2Ff_auto&publicId=woman-blackdress-stairs)

![Original](https://res.cloudinary.com/demo/image/upload/c_scale,h_300/woman-blackdress-stairs.jpg "Original") [![Transformed image](https://res.cloudinary.com/demo/image/upload/c_thumb,g_face,h_200,w_200/r_max/f_auto/woman-blackdress-stairs.png "Transformed image")](https://res.cloudinary.com/demo/image/upload/c_thumb,g_face,h_200,w_200/r_max/f_auto/woman-blackdress-stairs.png) **Transformed image**

Tip

You can use the [Media Library](https://cloudinary.com/documentation/media_library_for_developers) to preview and manage your transformations:
- [Quickly test transformations](https://cloudinary.com/documentation/media_library_for_developers#quick_delivery_testing) in the Media Library by opening the image URL and manually adding transformations before implementing them programmatically.
- [Manage derived assets](https://cloudinary.com/documentation/media_library_for_developers#derived_assets) from the **Derived Assets** tab in an asset's Manage page.

## Transformation URL syntax

Your Cloudinary media assets are accessed using simple delivery HTTP or HTTPS URLs, which are then delivered to users via a worldwide fast CDN. The URL contains the **public ID** of the requested asset plus any optional transformation parameters. The public ID is the unique identifier of the asset and is either defined when uploading the asset to Cloudinary, or automatically assigned by Cloudinary (see [Uploading Assets](https://cloudinary.com/documentation/upload_parameters#public_id) for more details on the various options for specifying the public ID).

#### Generating transformation URLs with Cloudinary SDKs

Cloudinary's [SDKs](https://cloudinary.com/documentation/cloudinary_sdks) automatically build the transformation URL for you. They allow you to continue working in your preferred developer framework and also provide helper methods to simplify building image tags and image transformation URLs.

Tip

You can also create your transformation URLs using the [Transformation Builder](https://cloudinary.com/documentation/named_transformations#transformation_builder). Alternatively, you can take one of our transformations from the [Image Home Transformations Gallery](https://console.cloudinary.com/app/image/home) as a starting point and then further modify it in the Transformation Builder to fit your needs. The Transformation Builder generates the URL and SDK code for the transformation you define so that you can copy it in the language you require.

### Transformation URL structure

The default Cloudinary asset delivery URL has the following structure:

https://res.cloudinary.com/<cloud\_name>/<asset\_type>/<delivery\_type>/<transformations>/<version>/<public\_id>.<extension>

| element | description |
| --- | --- |
| cloud\_name | A unique public identifier for your product environment, used for URL building and API access.  **Note**: Paid customers on the [Advanced plan](https://cloudinary.com/pricing) or higher can request to use a [private CDN or custom delivery hostname (CNAME)](https://cloudinary.com/documentation/advanced_url_delivery_options#private_cdns_and_custom_delivery_hostnames_cnames) to customize the domain name used for your delivery URLs. |
| asset\_type | The type of asset to deliver. Valid values: `image`, `video`, or `raw`. - The `image` type includes still image and photo formats, animated images, PDFs, layered files, such as TIFF and PSD, and others. - The `video` type includes video and audio files. - The `raw` type includes any file uploaded to Cloudinary that does not fit in one of the above categories. In general, transformations cannot be performed on `raw` assets, but they can be delivered as-is for download purposes, or in some cases, they may be used in conjunction with your image or video transformations. |
| delivery\_type | The storage or delivery type. For details on all possible types, see [Delivery types](https://cloudinary.com/documentation/image_trans_flags_delivery_types#delivery_types). |
| transformations | Optional. One or more comma-separated [transformation parameters](https://cloudinary.com/documentation/transformation_reference) in a single URL component, or a set of [chained transformations](#chained_transformations) in multiple URL components (separated by slashes). When the transformation URL is first accessed, the derived media file is created on the fly and delivered to your user. The derived file is also cached on the CDN and is immediately available to all subsequent users requesting the same asset. |
| version | Optional. You can include the version in your delivery URL to bypass the cached version on the CDN and force delivery of the latest asset (in the case that an asset has been overwritten with a newer file). For simplicity, the version component is generally not included in the example URLs on this page. For details, see [Asset versions](#asset_versions). |
| public\_id | The unique identifier of the asset, including the [folder structure](https://cloudinary.com/documentation/upload_parameters#public_id) if relevant. |
| extension | Optional. The file extension of the requested delivery format for the asset. Default: The originally uploaded format or the format determined by [f\_auto](#automatic_format_selection_f_auto), when used. |

In the most general case of simply delivering images that were uploaded to your Cloudinary product environment without any transformations, the delivery URL will be in the format:

`  https://res.cloudinary.com/<cloud_name>/image/upload/<public_id>.<extension>  `

For example, delivering the image with a public ID of: `leather_bag_gray`, from the `demo` product environment in `jpg` format:

```
https://res.cloudinary.com/demo/image/upload/leather_bag_gray.jpg
```

[

Open In Studio

](https://tx-studio.cloudinary.com/?publicId=leather_bag_gray)

[![Sample image](https://res.cloudinary.com/demo/image/upload/w_500/leather_bag_gray.jpg "Sample image")](https://res.cloudinary.com/demo/image/upload/leather_bag_gray.jpg)

The following shows an example of delivering the same image, this time with transformation parameters applied, so that the image is scaled down and then cropped to fill a 250px square (aspect ratio of 1:1 = 1.0) and then a light blue border is applied:

```
https://res.cloudinary.com/demo/image/upload/ar_1.0,c_fill,h_250/bo_5px_solid_lightblue/leather_bag_gray.jpg
```

[

Open In Studio

](https://tx-studio.cloudinary.com/?transformationString=ar_1.0%2Cc_fill%2Ch_250%2Fbo_5px_solid_lightblue&publicId=leather_bag_gray)

[![Image cropped to 250*250px](https://res.cloudinary.com/demo/image/upload/ar_1.0,c_fill,h_250/bo_5px_solid_lightblue/leather_bag_gray.jpg "Image cropped to 250*250px")](https://res.cloudinary.com/demo/image/upload/ar_1.0,c_fill,h_250/bo_5px_solid_lightblue/leather_bag_gray.jpg)

#### Transformation URL tips

- For customers with a [Custom delivery hostname (CNAME)](https://cloudinary.com/documentation/advanced_url_delivery_options#private_cdns_and_custom_delivery_hostnames_cnames) - available for Cloudinary's Advanced plan and above - the basic image delivery URL becomes: `https://<custom delivery hostname>/image/upload....`
- You can convert and deliver your image in other supported image formats by simply changing the image format file extension. For details, see [Delivering in a different format](#delivering_in_a_different_format).
- You can append an SEO-friendly suffix to your URL by replacing the `image/upload` element of the URL with `images` and then appending the desired suffix with a slash (/) after the public ID and before the extension. For example, if you have a cooking image with a random public ID like: `abc1def2`, you can deliver your image as:
	`https://res.cloudinary.com/<cloud_name>/images/upload/a12345/cooking.jpg`
	For more details, see [Dynamic SEO suffixes](https://cloudinary.com/documentation/advanced_url_delivery_options#dynamic_seo_suffixes).
- You can also use shortcut URLs when specifically delivering image files using the default `upload` type. With Cloudinary's [Root Path URL](https://cloudinary.com/documentation/advanced_url_delivery_options#root_path_urls) feature, the `<asset_type>` and `<delivery_type>` elements can be omitted from the URL (they automatically default to the values `image` and `upload` respectively). For example, the Root Path shortcut delivery URL for the cropped image above is:
	`https://res.cloudinary.com/demo/c_crop,h_200,w_300/sample.jpg`

#### Transformation URL video tutorial

The following video provides a quick demonstration of how dynamic transformation URLs work with both images and videos.

This video is brought to you by Cloudinary's video player - [embed your own](https://cloudinary.com/documentation/cloudinary_video_player)!  
Use the controls to set the playback **speed**, navigate to **chapters** of interest and select **subtitles** in your preferred language.

#### Tutorial contents

### Parameter types

There are two types of transformation parameters:

- **Action parameters**: Parameters that perform a specific transformation on the asset.
- **Qualifier parameters**: Parameters that do not perform an action on their own, but rather alter the default behavior or otherwise adjust the outcome of the corresponding action parameter.

It's best practice to include only one action parameter per URL component.

If you want to apply multiple **actions** in a single transformation URL, apply them in separate [chained](#chained_transformations) components, where each action is performed on the result of the previous one.

Note

In some of the Cloudinary SDKs, this action separation rule is enforced.

In contrast, **qualifier** parameters *must* be included in the component with the action parameter they qualify.

- Most qualifiers are optional, meaning the related action parameter can be used independently, but you can add optional qualifiers to modify the default behavior.
- In some cases, an action parameter **requires** one or more qualifiers to fully define the transformation behavior.
- There are a few parameters that can be used independently as action parameters, but can also be used in other scenarios as a qualifier for another action.

For example, the transformation below includes multiple transformation actions. The qualifier transformations included together with a particular action define additional adjustments on the transformation action's behavior:

```
https://res.cloudinary.com/demo/image/upload/ar_1.0,c_thumb,g_face,w_0.7/r_max/co_skyblue,e_outline/co_lightgray,e_shadow,x_5,y_8/docs/blue_sweater_model.png
```

[

Open In Studio

](https://tx-studio.cloudinary.com/?transformationString=ar_1.0%2Cc_thumb%2Cg_face%2Cw_0.7%2Fr_max%2Fco_skyblue%2Ce_outline%2Fco_lightgray%2Ce_shadow%2Cx_5%2Cy_8&publicId=docs%2Fblue_sweater_model)

[![Multiple transformation actions in a chained transformation](https://res.cloudinary.com/demo/image/upload/ar_1.0,c_thumb,g_face,w_0.7/r_max/co_skyblue,e_outline/co_lightgray,e_shadow,x_5,y_8/w_300/docs/blue_sweater_model.png "Multiple transformation actions in a chained transformation")](https://res.cloudinary.com/demo/image/upload/ar_1.0,c_thumb,g_face,w_0.7/r_max/co_skyblue,e_outline/co_lightgray,e_shadow,x_5,y_8/docs/blue_sweater_model.png)

Note

The URL tab above shows the URL as it looks when generated by an SDK. SDKs always generate the parameters within a specific URL component in alphabetical order (thus some qualifiers in the URL may come before the action that they qualify).

In this transformation:

- The [aspect ratio](https://cloudinary.com/documentation/transformation_reference#ar_aspect_ratio), [gravity](https://cloudinary.com/documentation/transformation_reference#g_gravity), and [width](https://cloudinary.com/documentation/transformation_reference#w_width) qualifiers control the way the [thumbnail crop](https://cloudinary.com/documentation/transformation_reference#c_thumb) action will be performed.
- The [rounding](https://cloudinary.com/documentation/transformation_reference#r_round_corners) action doesn't have any qualifiers.
- The [color](https://cloudinary.com/documentation/transformation_reference#co_color) qualifier overrides the default color of the [outline effect](https://cloudinary.com/documentation/transformation_reference#e_effect) action.
- The [color](https://cloudinary.com/documentation/transformation_reference#co_color) qualifier overrides the default [shadow effect](https://cloudinary.com/documentation/transformation_reference#e_shadow) color, while the [x and y](https://cloudinary.com/documentation/transformation_reference#x_y_coordinates) qualifiers adjust its placement.

### Asset versions

The **version** component is an optional part of Cloudinary delivery URLs that can be added to bypass the CDN cached version and force delivery of the newest asset. Cloudinary returns the value of the `version` parameter as part of every [upload response](https://cloudinary.com/documentation/upload_images#upload_response), and the returned `url` and `secure_url` parameters also include the `version` component, which represents the timestamp of the upload.

- Delivering the URL without a version value will deliver the cached version on the CDN if available or will request the latest version from Cloudinary if not cached (or when the cached version expires).
- Delivering the URL with a version will deliver the cached CDN version only if the cached version matches the requested version number. Otherwise, it will bypass the cached CDN version and immediately request and deliver the latest version from Cloudinary.

Example image delivery URL without version:

```
https://res.cloudinary.com/demo/image/upload/water-park-aerial-view.jpg
```

Example image delivery URL with version:

```
https://res.cloudinary.com/demo/image/upload/v1699883548/water-park-aerial-view.jpg
```

Tip

As an alternative to using versions to ensure that a new version of an asset is delivered, you can set the `invalidate` parameter to `true` while uploading a new version of an asset. This invalidates the previous version of the media asset throughout the CDN. Note that it usually takes between a few seconds and a few minutes for the invalidation to fully propagate through the CDN. Using a new `version` value in a URL takes effect immediately, but requires updating your delivery URLs in your production code. For details on invalidating media assets, see [Invalidating cached media assets on the CDN](https://cloudinary.com/documentation/invalidate_cached_media_assets_on_the_cdn).

## Embedding images in web pages using SDKs

You access uploaded images or their derived transformations with URLs. These URLs can be used as the `<src>` of the `<img>` tags in your HTML code or other frontend functions to deliver your media assets.

The easiest way to deliver them is using Cloudinary's framework SDKs to automatically generate transformation URLs and embed them using HTML image tags. The SDKs offer two main helper methods: the **URL helper** and the **image tag helper**.

### Cloudinary URL helper method

**To generate an asset source URL using the URL helper method:**

Use the **Cloudinary URL helper method** (e.g., `cloudinary_url` in the Ruby/Rails SDK) to automatically generate the image source URL.

For example, the following uses the URL helper method to return the URL of the `leather_bag_gray` image, padded to a scaled width and height of 300 pixels with a blue background for the padding:

```
cloudinary.url("sample.jpg", {background: "blue", height: 300, width: 300, crop: "pad"})
```

[

Open In Studio

](https://tx-studio.cloudinary.com/?transformationString=b_blue%2Cc_pad%2Ch_300%2Cw_300&publicId=sample)

This SDK code outputs the URL:

```
https://res.cloudinary.com/demo/image/upload/b_blue,c_pad,h_300,w_300/sample.jpg
```

### Cloudinary image tag helper method

**To generate a complete HTML image tag:**

Use the **Cloudinary image tag helper method** (e.g., `cl_image_tag` in Ruby on Rails) to automatically generate an HTML image tag including the image source URL.

The following shows the same transformations as above, but this time using the image tag to generate a complete HTML image tag.

```
cloudinary.image("sample.jpg", {height: 100, width: 300, crop: "scale"})
```

[

Open In Studio

](https://tx-studio.cloudinary.com/?transformationString=c_scale%2Ch_100%2Cw_300&publicId=sample)

This SDK code will output the following HTML code:

```
<img 
  src="https://res.cloudinary.com/demo/image/upload/c_scale,h_100,w_300/sample.jpg"
>
```

**To add HTML attributes to your image tag:**

Use the Cloudinary Image Tag helper method to specify both Cloudinary transformation parameters and regular HTML image tag attributes (e.g., alt, title, width, height).

For example, the following uses the Image Tag helper method to create an HTML image tag for the `sample` image, with the 'alt' attribute set to "A sample photo" and the 'className' attribute set to "Samples":

```
cloudinary.image("sample.jpg", {alt: "A sample photo", className: "Samples"})
```

For more information on these SDK helper methods, see the transformation documentation in the relevant [SDK guide](https://cloudinary.com/documentation/cloudinary_sdks).

Tip

In general, when using an SDK, you will probably take advantage of the SDK parameter names for improved readability and maintenance of your code. However, you can also optionally pass a **raw\_transformation** parameter, whose value is a literal [URL transformation](https://cloudinary.com/documentation/transformation_reference) definition. Note that the string you pass as the raw transformation value will be appended as is (with no processing or validation) to the **end** of any other transformation parameters passed in the same component of the transformation chain.

For example:

```
cloudinary.image("sample.jpg", { transformation: { raw_transformation: "w_400,c_pad" }})
```

## Chained Transformations

Cloudinary supports powerful transformations that are applied on the fly using dynamic URLs. You can combine multiple transformation actions together as part of a single delivery request, e.g., crop an image and then add a border to it.

In general, it's best practice to **chain** each transformation [action](#parameter_types) in your URL as a separate component in the chain.

To support chained transformations, Cloudinary's transformation URLs allow you to include multiple transformation components, each separated by a slash (`/`), where each of the transformation components is executed on the result of the previous one. Cloudinary's SDKs can apply multiple transformation components by specifying the `transformation` parameter and setting it to an array of transformation maps.

Examples:

1. Three chained transformations: fill to a 250px square, then round to a circle, and deliver in the optimal transparent format:
	```
	https://res.cloudinary.com/demo/image/upload/ar_1.0,c_fill,w_250/r_max/f_auto/livingroom-yellow-chair.png
	```
	[
	Open In Studio
	](https://tx-studio.cloudinary.com/?transformationString=ar_1.0%2Cc_fill%2Cw_250%2Fr_max%2Ff_auto&publicId=livingroom-yellow-chair)
	[![2 chained transformations applied to an image](https://res.cloudinary.com/demo/image/upload/ar_1.0,c_fill,w_250/r_max/f_auto/livingroom-yellow-chair.png "2 chained transformations applied to an image")](https://res.cloudinary.com/demo/image/upload/ar_1.0,c_fill,w_250/r_max/f_auto/livingroom-yellow-chair.png)
2. Five chained transformations: Fill to a 250\*400px portrait, then rotate the result by 20 degrees, then add a brown outline to the rotated image, and optimize the resulting image to deliver with the best compression that gives good visual quality and in the optimal transparent format:
	```
	https://res.cloudinary.com/demo/image/upload/c_fill,h_400,w_250/a_20/e_outline,co_brown/q_auto/f_auto/kitchen-island.png
	```
	[
	Open In Studio
	](https://tx-studio.cloudinary.com/?transformationString=c_fill%2Ch_400%2Cw_250%2Fa_20%2Fe_outline%2Cco_brown%2Fq_auto%2Ff_auto&publicId=kitchen-island)
	[![4 chained transformations applied to an image](https://res.cloudinary.com/demo/image/upload/c_fill,h_400,w_250/a_20/e_outline,co_brown/q_auto/f_auto/h_350,dpr_2/kitchen-island.png)
	4 chained transformations applied to an image
	](https://res.cloudinary.com/demo/image/upload/c_fill,h_400,w_250/a_20/e_outline,co_brown/q_auto/f_auto/kitchen-island.png)

Related topics

While learning about image transformations, you may also want to check out:
- [Named transformations](https://cloudinary.com/documentation/named_transformations): Create and reuse saved transformation presets.
- [Image format support](https://cloudinary.com/documentation/image_format_support): Supported image formats and automatic format selection.
- [Image transformation types](https://cloudinary.com/documentation/image_transformation_types): Overview of all available transformation types, including ways to create new image assets.
- [Transformation flags and delivery types](https://cloudinary.com/documentation/image_trans_flags_delivery_types): Details on delivery types, parameter types, transformation flags, and URL syntax options.
- [Image delivery and optimization](https://cloudinary.com/documentation/image_delivery_options): Optimize and deliver images responsively.
- [Transformation URL API Reference](https://cloudinary.com/documentation/transformation_reference): Details all available transformation parameters. Icons indicate which parameters are supported for each asset type.
- [Video transformations guide](https://cloudinary.com/documentation/video_manipulation_and_delivery): Provides details and examples of the transformations you can apply to video assets.
- [How are transformations counted?](https://cloudinary.com/documentation/transformation_counts): Details how various transformations are counted for monthly billing.
- [Troubleshooting image transformation errors](https://cloudinary.com/documentation/ts_troubleshooting_image_transformation_errors): If you encounter errors with your transformation URLs, use the X-Cld-Error inspector tool and learn about common issues and solutions.

Feedback sent!