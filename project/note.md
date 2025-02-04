## python matlab 이미지가 다른이유
matlab imagesc는 y축이 위 -> 아래 증가
python imshow는 y축이 아래 -> 위 증가

# python extent=[] 구조
plt.imshow(image, extent=[left, right, bottom, top])