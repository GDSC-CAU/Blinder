from fastapi import FastAPI, File, UploadFile
import cv2
import imutils
from imutils.perspective import four_point_transform
from enum import Enum
import io
import os
import uuid
from google.cloud import vision
from dotenv import load_dotenv

class FeatureType(Enum):
    PAGE = 1
    BLOCK = 2
    PARA = 3
    WORD = 4
    SYMBOL = 5

def crop(img_path: str):
    big_img = cv2.imread(img_path)
    ratio = big_img.shape[0] / 500.0
    org = big_img.copy()
    img = imutils.resize(big_img, height=500)

    gray_img = cv2.cvtColor(img.copy(), cv2.COLOR_BGR2GRAY)
    blur_img = cv2.GaussianBlur(gray_img, (5, 5), 0)
    edged_img = cv2.Canny(blur_img, 75, 200)

    cnts, _ = cv2.findContours(edged_img.copy(), cv2.RETR_LIST, cv2.CHAIN_APPROX_SIMPLE)
    cnts = sorted(cnts, key=cv2.contourArea, reverse=True)[:5]
    doc = None  # Initialize doc to None
    for c in cnts:
        peri = cv2.arcLength(c, True)
        approx = cv2.approxPolyDP(c, 0.02 * peri, True)
        if len(approx) == 4:
            doc = approx
            break
        else:
            result = img  # 꼭짓점이 인식되지 않았을 경우 원본이미지 반환
            return result

    if doc is None:  # Check if doc is assigned
        result = img
        return result  # Return if doc is not assigned

    p = []
    for d in doc:
        tuple_point = tuple(d[0])
        cv2.circle(img, tuple_point, 3, (0, 0, 255), 4)
        p.append(tuple_point)
    # cv2.imwrite(cornered_path, img)     #확인용

    result = four_point_transform(org, doc.reshape(4, 2) * ratio)
    return result


app = FastAPI()

# BASE_DIR = os.path.dirname(os.path.abspath(os.path.abspath(_)))
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))
UPLOAD_DIR = "./tmp"
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = './api-key.json'



@app.get("/")
async def root():
    return {"message": "Hello Blinder"}


@app.post("/ocr")
async def ocr(file: UploadFile):
    content = await file.read()
    original_filename = f"{str(uuid.uuid4())}original.jpg"  # uuid로 유니크한 파일명으로 변경
    cropped_filename = f"{str(uuid.uuid4())}cropped.jpg"
    with open(os.path.join(UPLOAD_DIR, original_filename), "wb") as fp:
        fp.write(content)  # 서버 로컬 스토리지에 이미지 저장 (쓰기)

    original_path = './tmp'
    cropped_path = './tmp'
    img_path = os.path.join(original_path, original_filename)
    cropped_path = os.path.join(cropped_path, cropped_filename)

    result = crop(img_path)

    cv2.imwrite(cropped_path, result)


    client = vision.ImageAnnotatorClient()

    data = []

    # API 요청
    with io.open(cropped_path, "rb") as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.document_text_detection(image=image)
    document = response.full_text_annotation
    # # Collect specified feature bounds by enumerating all document features
    for page in document.pages:
        for block in page.blocks:
            for paragraph in block.paragraphs:
                for word in paragraph.words:
                    text = ""
                    vertices = [
                        [word.bounding_box.vertices[0].x, word.bounding_box.vertices[0].y],
                        [word.bounding_box.vertices[1].x, word.bounding_box.vertices[1].y],
                        [word.bounding_box.vertices[2].x, word.bounding_box.vertices[2].y],
                        [word.bounding_box.vertices[3].x, word.bounding_box.vertices[3].y],
                    ]
                    for symbol in word.symbols:
                        text += symbol.text
                    data.append({"text": text, "vertices": vertices})
                    # bounds.append(paragraph.bounding_box)
                # bounds.append(block.bounding_box)

    os.remove(img_path)
    os.remove(cropped_path)

    return {"message": "ocr", "data": data}
