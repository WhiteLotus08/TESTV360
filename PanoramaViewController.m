#import "PanoramaViewController.h"

#import "GVROverlayView.h"
#import <GVRKit/GVRKit.h>

#import <AVKit/AVKit.h>

static const CGFloat kMargin = 16;
static const CGFloat kPanoViewHeight = 250;

@interface PanoramaViewController ()<GVRRendererViewControllerDelegate>
@property(nonatomic) GVRRendererView *panoView;
@end

@implementation PanoramaViewController {
  UIScrollView *_scrollView;
  UILabel *_titleLabel;
  UILabel *_subtitleLabel;
  UILabel *_preambleLabel;
  UILabel *_captionLabel;
  UILabel *_postambleLabel;
  UITextView *_attributionTextView;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.title = @"Panorama";
  self.view.backgroundColor = [UIColor whiteColor];

  _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
  _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  [self.view addSubview:_scrollView];

  _titleLabel =
      [self createLabelWithFontSize:20 bold:YES text:@"Machu Picchu\nWorld Heritage Site"];
  [_scrollView addSubview:_titleLabel];

  _subtitleLabel = [self createLabelWithFontSize:14 text:@"The world-famous citadel of the Andes"];
  _subtitleLabel.textColor = [UIColor darkGrayColor];
  [_scrollView addSubview:_subtitleLabel];

  _preambleLabel =
      [self createLabelWithFontSize:16
                               text:@"Laurentino aburrido en IBM "
                               @"Mountains in Peru, above the Urubamba River valley."];
  [_scrollView addSubview:_preambleLabel];

  GVRRendererViewController *viewController = [[GVRRendererViewController alloc] init];
  viewController.delegate = self;
  _panoView = viewController.rendererView;
  [_scrollView addSubview:_panoView];
  [self addChildViewController:viewController];

  _captionLabel = [self createLabelWithFontSize:14 text:@"A 360 panoramic view of Machu Picchu"];
  _captionLabel.textColor = [UIColor darkGrayColor];
  [_scrollView addSubview:_captionLabel];

  _postambleLabel = [self
      createLabelWithFontSize:16
                         text:@"Chief me va a regañar porque no he terminado el codigo de VR"
                         @"poll."];
  [_scrollView addSubview:_postambleLabel];

  // Build source attribution text view.
  NSString *sourceText = @"Source: ";
  NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc]
      initWithString:[sourceText stringByAppendingString:@"Wikipedia"]];
  [attributedText
      addAttribute:NSLinkAttributeName
             value:@"https://en.wikipedia.org/wiki/Machu_Picchu"
             range:NSMakeRange(sourceText.length, attributedText.length - sourceText.length)];

  _attributionTextView = [[UITextView alloc] init];
  _attributionTextView.editable = NO;
  _attributionTextView.attributedText = attributedText;
  _attributionTextView.font = [UIFont systemFontOfSize:16];
  [_scrollView addSubview:_attributionTextView];
  [_scrollView setAccessibilityIdentifier:@"sample_scroll_view"];
}

- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];

  [self setFrameForView:_titleLabel belowView:nil margin:kMargin];
  [self setFrameForView:_subtitleLabel belowView:_titleLabel margin:kMargin];
  [self setFrameForView:_preambleLabel belowView:_subtitleLabel margin:kMargin];

  _panoView.frame = CGRectMake(kMargin,
                               CGRectGetMaxY(_preambleLabel.frame) + kMargin,
                               CGRectGetWidth(self.view.bounds) - 2 * kMargin,
                               kPanoViewHeight);
  [self setFrameForView:_captionLabel belowView:_panoView margin:kMargin];
  [self setFrameForView:_postambleLabel belowView:_captionLabel margin:kMargin];
  [self setFrameForView:_attributionTextView belowView:_postambleLabel margin:kMargin];

  _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds),
                                       CGRectGetMaxY(_attributionTextView.frame) + kMargin);
}

#pragma mark - GVRRendererViewControllerDelegate

- (GVRRenderer *)rendererForDisplayMode:(GVRDisplayMode)displayMode {
  UIImage *image = [UIImage imageNamed:@"Panorama/chapala.jpg"];
  GVRImageRenderer *imageRenderer = [[GVRImageRenderer alloc] initWithImage:image];
  [imageRenderer setSphericalMeshOfRadius:50
                                latitudes:12
                               longitudes:24
                              verticalFov:180
                            horizontalFov:360
                                 meshType:kGVRMeshTypeMonoscopic];

  GVRSceneRenderer *sceneRenderer = [[GVRSceneRenderer alloc] init];
  [sceneRenderer.renderList addRenderObject:imageRenderer];

  // Hide reticle in embedded display mode.
  if (displayMode == kGVRDisplayModeEmbedded) {
    sceneRenderer.hidesReticle = YES;
  }

  return sceneRenderer;
}

#pragma mark - Implementation

- (UILabel *)createLabelWithFontSize:(CGFloat)fontSize text:(NSString *)text {
  return [self createLabelWithFontSize:fontSize bold:NO text:text];
}

- (UILabel *)createLabelWithFontSize:(CGFloat)fontSize bold:(BOOL)bold text:(NSString *)text {
  UILabel *label = [[UILabel alloc] init];
  label.text = text;
  label.font = (bold ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize]);
  label.numberOfLines = 0;
  return label;
}

- (void)setFrameForView:(UIView *)view belowView:(UIView *)topView margin:(CGFloat)margin {
  CGSize size =
      [view sizeThatFits:CGSizeMake(CGRectGetWidth(self.view.bounds) - 2 * kMargin, CGFLOAT_MAX)];
  view.frame = CGRectMake(kMargin, CGRectGetMaxY(topView.frame) + margin, size.width, size.height);
}

@end
