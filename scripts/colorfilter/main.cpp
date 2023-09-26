#include "opencv2/opencv.hpp"

using namespace std;
using namespace cv;

int main(int argc, char *argv[]) {
    int nx, ny;
    Mat channels[3];

    Mat img = imread(argv[1]);

    Mat cell_small = imread("masksmall.bmp");
    Mat cell_mid = imread("maskmid.bmp");
    Mat cell_big = imread("maskbig.bmp");

    Mat mask_small;
    nx = img.size().width / cell_small.size().width + 1;
    ny = img.size().height / cell_small.size().height + 1;
    repeat(cell_small, ny, nx, mask_small);
    mask_small = mask_small(Range(0, img.size().height), Range(0, img.size().width));


    Mat mask_mid;
    nx = img.size().width / cell_mid.size().width + 1;
    ny = img.size().height / cell_mid.size().height + 1;
    repeat(cell_mid, ny, nx, mask_mid);
    mask_mid = mask_mid(Range(0, img.size().height), Range(0, img.size().width));

    Mat mask_big;
    nx = img.size().width / cell_big.size().width + 1;
    ny = img.size().height / cell_big.size().height + 1;
    repeat(cell_big, ny, nx, mask_big);
    mask_big = mask_big(Range(0, img.size().height), Range(0, img.size().width));

    Mat img_small = mask_small & img;
    split(img_small, channels);
    img_small = channels[0] + channels[1] + channels[2];

    Mat img_mid = mask_mid & img;
    split(img_mid, channels);
    img_mid = channels[0] + channels[1] + channels[2];

    Mat img_big = mask_big & img;
    split(img_big, channels);
    img_big = channels[0] + channels[1] + channels[2];
    
    imwrite(string(argv[1]) + ".small.jpg", img_small);
    imwrite(string(argv[1]) + ".mid.jpg", img_mid);
    imwrite(string(argv[1]) + ".big.jpg", img_big);
    return 0;
}