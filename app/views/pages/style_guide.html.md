# Style Guide for In Her Own Right Static Pages
<hr />
## Overview and prerequisites

The following is a guide for managing the static, interpretive and contextual content included in the In Her Own Right search and data aggregation tool. Below are detailed instructions for making a simple page with GitHub, some pre-made templates users can copy and paste into a page, and instructions to start a small Jekyll application for contributors who would like to preview and customize their work. If you have any questions or need help, feel free to email William Bolton (will@neomindlabs.com).

For a better writing experience, the static pages render <a href="https://daringfireball.net/projects/markdown/syntax" target="_blank" >Markdown</a>. They are also smart enough to evaluate HTML, CSS, and JavaScript. This means contributors can create their own <span style="color: red;">styles</span> if they include custom HTML and CSS in the page and can even write JavaScript (click <span id="sample_span" style="color: blue">here</span> to see some JS) if they would like.

In order to keep management of this material simple, flexible, and versioned, the static content is directly integrated into the code base with pull requests initiated at GitHub.

The only prerequisites for making a contribution request are a <a href="https://github.com/" target="_blank" >GitHub</a> account and access to the In Her Own Right GitHub repository.

## Structure

The static pages for this site are located in the `/app/views/pages/` directory. Each sub-directory within the `pages` directory generates a dropdown menu in the main site navigation that will link to every page nested within it. For example, `app/views/pages/about/pacscl.html.md` will generate a dropdown menu called "About" with one link to a static page called "Pacscl."

Static pages placed directly into the `pages` directory still render on the website (like this one), though links to them are not automatically in the main page's navigation. This means it would be possible to include pages on the site that would not appear in the main navigation, though you could link to them internally. If a link needs to be created to a specific static page from parts of the site that are dynamically generated, please contact the administrators of the code base.

## How to make a new static page with GitHub and submit a pull request

Here are step-by-step instructions for making a simple page.

1. After you have set up your GitHub account and logged in, navigate to the In Her Own Right project repository, currently located at <a href="https://github.com/" target="blank" >https://github.com/NeomindLabs/pacscl</a>.

2. Click on `app` > `views` > `pages`. Now you have a choice:
  <br/>
  * If you would like to **create a new dropdown menu in the main navigation**, click the `Create new file` button. When you name this file, you will need to add a directory to the file name. In the `Name your file` field, your file name should look like this with a sub-directory name and a slash before the file name: `new-menu-item/my-new-page.html.md`.
  <br/>
  <br/>
  * If you would like your **new page to be part of an existing dropdown menu**, click the menu item that you would like, and name your file like this: `my-new-page.html.md`.
  <br/>
  <br/>

3. Now you can edit the page or copy and paste what ever you like into the page.

4. If your page uses fairly simple Markdown, you can click the preview link to see how the Markdown will render.

5. When you have finished editing the page and are ready to submit a pull request, scroll to the bottom of the page. In the `Commit new file` form, you can write a brief description of the file to send to the project maintainers.

6. Next, select the `Create a new branch for this commit and start a pull request.` option and give your new branch a name. When you click `Propose new file` an email will be sent to the project maintainers who will review your work and merge it into the code base.

## Static Images

It is possible add static images to the static pages. Like this:

<figure class="figure">
  <img src="/static_images/sample_image.png" class="figure-img img-fluid rounded" alt="A sample image.">
  <figcaption class="figure-caption text-left">A caption for the above image.</figcaption>
</figure>
<br />

Here is how to do this:

1. Navigate to the In Her Own Right project repository.

2. Click on `public` > `static_images`

3. From here, click `Upload files` and either upload or drag the file into the upload form.

4. Submit a pull-request, as described above.

5. To have the image appear in your page, use the following code snippet, but replace the file name with the name of the actual file in the `src` attribute of the `img` element:

  ```
    <br/>
    <figure class="figure">
      <img src="/static_images/sample_image.png">
      <figcaption class="figure-caption text-right">A caption for the above image.</figcaption>
    </figure>
    <br/>
  ```

## Sample Code for Likely Style Needs

The following are some snippets of code that might be useful for likely formatting needs. This page's file is located at `app/views/pages/style_guide.html.md` where you will find these snippets to copy and paste into your own file. The entire project uses <a href="https://v4-alpha.getbootstrap.com/" target="_blank">Bootstrap</a>, so you can modify these snippets following the Bootstrap documentation for fairly expected results.
<hr />
#### Basic Markdown

Here is a little bit of the basic code that is used for Markdown styling:

# Header 1
## Header 2
### Header 3
#### Header 4
##### Header 5

Paragraphs are just text with a space above them.

_Italics_ or *italics*

**Bold**

[This is a link to Google.](http://google.com) If you want your link to open a new page / tab, you will have to use HTML like this:

```
  <a href="http://google.com" target="_blank" >Google</a>
```

> This is a block quote. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iure error, ipsa quia corporis fuga nostrum laborum consequatur culpa odio quo soluta, sit nesciunt cupiditate. Amet cum, odio placeat. Ducimus, commodi.

This is a footnote callout.[^1] You will find the corresponding note at the bottom of the page.

<hr style="border-top: 1px solid #CCCCCC; width: 100"><hr />

#### Section break (not visable `<hr/>`)
<hr />

<hr style="border-top: 1px solid #CCCCCC; width: 100"><hr />
#### Section break with a horizontal line

<hr style="border-top: 1px solid #CCCCCC; width: 100"><hr />
<hr style="border-top: 1px solid #CCCCCC; width: 100"><hr />

#### A text block with an image to the right:
<hr />

<div class="row">
  <div class="col-md-6">
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit. Facilis autem id doloribus voluptates a dolorem quae recusandae eos, unde doloremque veniam vel modi nobis fuga qui laboriosam tempore hic voluptatibus? Lorem ipsum dolor sit amet, consectetur adipisicing elit. Suscipit qui, nesciunt maxime. Nisi reiciendis, quae perferendis, quo totam facilis! Similique est impedit pariatur vel aperiam laboriosam magni quas unde quis.
    </p>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit. Facilis autem id doloribus voluptates a dolorem quae recusandae eos, unde doloremque veniam vel modi nobis fuga qui laboriosam tempore hic voluptatibus? Lorem ipsum dolor sit amet, consectetur adipisicing elit. Suscipit qui, nesciunt maxime. Nisi reiciendis, quae perferendis, quo totam facilis! Similique est impedit pariatur vel aperiam laboriosam magni quas unde quis.
    </p>
  </div>
  <div class="col-md-6">
    <figure class="figure">
      <img src="/static_images/sample_image.png" class="figure-img img-fluid rounded" alt="A sample image.">
      <figcaption class="figure-caption text-left">A caption for the above image.</figcaption>
    </figure>
  </div>
</div>

<hr style="border-top: 1px solid #CCCCCC; width: 100"><hr />

#### A text block with an image to the left:
<hr />

<div class="row">
  <div class="col-md-6">
    <figure class="figure">
      <img src="/static_images/sample_image.png" class="figure-img img-fluid rounded" alt="A sample image.">
      <figcaption class="figure-caption text-left">A caption for the above image.</figcaption>
    </figure>
  </div>
  <div class="col-md-6">
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit. Facilis autem id doloribus voluptates a dolorem quae recusandae eos, unde doloremque veniam vel modi nobis fuga qui laboriosam tempore hic voluptatibus? Lorem ipsum dolor sit amet, consectetur adipisicing elit. Suscipit qui, nesciunt maxime. Nisi reiciendis, quae perferendis, quo totam facilis! Similique est impedit pariatur vel aperiam laboriosam magni quas unde quis.
    </p>
    <p>
      Lorem ipsum dolor sit amet, consectetur adipisicing elit. Facilis autem id doloribus voluptates a dolorem quae recusandae eos, unde doloremque veniam vel modi nobis fuga qui laboriosam tempore hic voluptatibus? Lorem ipsum dolor sit amet, consectetur adipisicing elit. Suscipit qui, nesciunt maxime. Nisi reiciendis, quae perferendis, quo totam facilis! Similique est impedit pariatur vel aperiam laboriosam magni quas unde quis.
    </p>
  </div>
</div>

<hr style="border-top: 1px solid #CCCCCC; width: 100"><hr />

#### A table with headers:
<hr />
<div class="container">
  <table class="table">
    <thead>
      <tr>
        <th>Author</th>
        <th>Title</th>
        <th>Year</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Douglass, S. M. (Sarah Mapps)</td>
        <td>Letter from Sarah Mapps Douglass to Rebecca White 1816 December 16</td>
        <td>12-16-1861</td>
      </tr>
      <tr>
        <td>Parrish, Helen L.</td>
        <td>Helen Parrish Papers, Diaries, 1888, vol. 1</td>
        <td>1888</td>
      </tr>
      <tr>
        <td>Philips, Mildred M.</td>
        <td>03-12-1885</td>
        <td>Report of the Proceedings of the Tenth Annual Meeting of the Alumnae Association of the Woman's Medical College of Pennsylvania, March 12, 1885.</td>
      </tr>
    </tbody>
  </table>
</div>

<hr style="border-top: 1px solid #CCCCCC; width: 100"><hr />

## Preview a Static Page Using Jekyll

For contributors who would like to preview their changes live or do some more complex design / formatting work, the In Her Own Right project includes a miniature Jekyll app which is designed to render a singe sample static page. After developing the page to their liking in the Jekyll app, a contributor can start the pull request process described above, and copy and paste the contents of their file into the new file in GitHub.

For help setting this up, feel free to email William Bolton (will@neomindlabs.com).

### Prerequisites

* The directions here are intended for users with a Mac or other computer with easy access to a Linux shell.
* A text editor would be handy. A text editor with some familiar GUI-type features for beginners (and with a generous free trial period) is <a href="https://www.sublimetext.com/" target="_blank">SublimeText</a>.

### Run the Jekyll App Locally

1. First download or clone the In Her Own Right project repository.

2. Open a terminal shell. If you have never done this on a Mac, hold down `command + space_bar` and start typing `terminal` into Spotlight Search. After you find the Terminal Utility, hit enter to open a terminal window. If you are not used to navigating your computer from the command line, you might want to look at a cheat sheet for some basic terminal commands. There are many good resources online.

3. `cd` into the folder where you have saved the In Her Own Right project and then `cd` into the folder called `sample_static_page`.

4. From here, type `ruby -v` in the terminal and hit enter. If you get a message that says something to the effect that Ruby is not installed, contact will@neomindlabs.com for further instructions.

5. Assuming you got a response that looks vaguely like this: `ruby 2.3.3p222 (2016-11-21 revision 56859) [x86_64-darwin16]`, type `gem install bundler` and hit return.

6. After `bundler` is finished installing, type `bundle install` and hit return.

7. After `bundler` finishes installing other dependencies, type `bundle exec jekyll serve` and hit enter to start a server in your terminal window. (Hit `control + c` to stop the server at any time).

8. From here, open a web browser and navigate to `http://localhost:4000/`

9. You can now edit `sample_static_page/_includes/sample_page.md` and the page will change every time you save this file and reload the browser.

10. You can place static images for testing purposes in the folder within the Jekyll app called `static_images`. The file structure is such that your link to the image will be exactly the same as the procedure described above.

11. When you are satisfied with your work, copy the code out of `sample_page.md` use it to make pull request as described above.

[^1]: This is a footnote which will link back to the note above.


<script type="text/javascript">
  var sampleSpan = $("#sample_span");
  sampleSpan.click(function(){
    alert('"This was clicked!"').html()
  });
</script>
