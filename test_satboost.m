test = rgb2hsv(img);
test(:,:,2) = test(:,:,2)*1.2;
test(test > 1) = 1;

test2 = hsv2rgb(test);

figure, imshow(img), title('og')
figure, imshow(test2), title('boosted');